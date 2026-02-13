defmodule AgentJido.ContentOps.OrchestratorAgent do
  @moduledoc """
  ContentOps orchestrator agent — single coordinator for content operations.

  Runs on a schedule (hourly/nightly/weekly/monthly), creates run contexts,
  executes a jido_runic workflow pipeline, and ensures all output flows
  through `content.change_request` signals.

  ## Workflow Pipeline

      BuildRunContext → LoadPolicyBundle → SelectWork → CollectChangeRequests → DeliverySink → PublishRunReport

  ## Modes

  - `:hourly` / `:nightly` — maintenance only (no work selection, 0 change requests)
  - `:weekly` / `:monthly` — creation sprint (selects work, produces synthetic change requests)

  ## Signals

  - Consumes: `contentops.tick`, `contentops.run.requested`
  - Emits: `contentops.run.completed` (via PubSub broadcast)
  """

  require Logger

  use Jido.Agent,
    name: "contentops_orchestrator",
    description: "ContentOps orchestrator — coordinates content creation and maintenance",
    strategy: {Jido.Runic.Strategy, workflow_fn: &__MODULE__.build_workflow/0},
    schema: [
      last_run_id: [type: :string, default: nil],
      last_run_mode: [type: :atom, default: nil],
      last_run_at: [type: :any, default: nil],
      total_runs: [type: :integer, default: 0]
    ],
    schedules: [
      {"0 * * * *", "contentops.tick", job_id: :hourly_tick},
      {"0 2 * * *", "contentops.tick", job_id: :nightly_tick},
      {"0 3 * * 1", "contentops.tick", job_id: :weekly_tick},
      {"0 4 1 * *", "contentops.tick", job_id: :monthly_tick}
    ]

  alias AgentJido.ContentOps.Actions.{
    BuildRunContext,
    LoadPolicyBundle,
    SelectWork,
    CollectChangeRequests,
    DeliverySink,
    PublishRunReport
  }

  alias Runic.Workflow

  @server_name AgentJido.ContentOps.OrchestratorServer

  @doc "Returns the registered name of the singleton orchestrator server."
  @spec server_name() :: atom()
  def server_name, do: @server_name

  @doc false
  @spec plugin_specs() :: [Jido.Plugin.Spec.t()]
  def plugin_specs, do: []

  @impl true
  def signal_routes(_ctx) do
    [
      {"contentops.tick", BuildRunContext},
      {"contentops.run.requested", BuildRunContext}
    ]
  end

  @doc """
  Build the orchestrator workflow DAG.

  All nodes run locally in the spike. The pipeline is linear:

      BuildRunContext → LoadPolicyBundle → SelectWork → CollectChangeRequests → DeliverySink → PublishRunReport
  """
  @spec build_workflow() :: struct()
  def build_workflow do
    Workflow.new(name: :contentops_pipeline)
    |> Workflow.add(BuildRunContext)
    |> Workflow.add(LoadPolicyBundle, to: :build_run_context)
    |> Workflow.add(SelectWork, to: :load_policy_bundle)
    |> Workflow.add(CollectChangeRequests, to: :select_work)
    |> Workflow.add(DeliverySink, to: :collect_change_requests)
    |> Workflow.add(PublishRunReport, to: :delivery_sink)
  end

  @doc """
  Run the orchestrator pipeline for a given mode.

  Sends a `runic.feed` signal to the singleton orchestrator server
  and waits for workflow completion.

  ## Options

    * `:mode` - Run mode (default: `:weekly`)
    * `:timeout` - Timeout in ms (default: `30_000`)

  ## Returns

  A map with `:mode`, `:status`, and `:productions`.
  """
  @spec run(keyword()) :: map()
  def run(opts \\ []) do
    mode = Keyword.get(opts, :mode, :weekly)
    timeout = Keyword.get(opts, :timeout, 30_000)

    Logger.info("[ContentOps] Starting #{mode} run")

    feed_signal =
      Jido.Signal.new!(
        "runic.feed",
        %{data: %{mode: mode}},
        source: "/contentops/orchestrator"
      )

    Jido.AgentServer.cast(@server_name, feed_signal)

    case Jido.AgentServer.await_completion(@server_name, timeout: timeout) do
      {:ok, %{status: :completed}} ->
        {:ok, server_state} = Jido.AgentServer.state(@server_name)
        strat = Jido.Agent.Strategy.State.get(server_state.agent)
        productions = Runic.Workflow.raw_productions(strat.workflow)

        Logger.info("[ContentOps] #{mode} run COMPLETED — #{length(productions)} productions")

        %{
          mode: mode,
          productions: productions,
          status: :completed
        }

      {:ok, %{status: :failed}} ->
        Logger.error("[ContentOps] #{mode} run FAILED")
        %{mode: mode, productions: [], status: :failed}

      {:error, reason} ->
        Logger.error("[ContentOps] #{mode} run ERROR: #{inspect(reason)}")
        %{mode: mode, productions: [], status: {:error, reason}}
    end
  end

  @doc "Extract the run report from pipeline results."
  @spec run_report(map()) :: map() | nil
  def run_report(%{productions: productions}) do
    Enum.find(productions, fn
      %{type: "contentops.run.completed"} -> true
      _ -> false
    end)
  end
end
