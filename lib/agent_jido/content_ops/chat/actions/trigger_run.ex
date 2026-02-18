defmodule AgentJido.ContentOps.Chat.Actions.TriggerRun do
  @moduledoc """
  Mutation tool that triggers a ContentOps run.
  """

  use Jido.Action,
    name: "contentops_trigger_run",
    description: "Trigger a ContentOps run (hourly/nightly/weekly/monthly)",
    schema:
      Zoi.object(%{
        mode:
          Zoi.enum([:hourly, :nightly, :weekly, :monthly], description: "Run cadence mode")
          |> Zoi.default(:weekly)
      })

  alias AgentJido.ContentOps.Chat.{OpsService, Policy}

  @impl true
  def run(params, context) do
    mode = params[:mode] || :weekly
    actor = Policy.actor_from_tool_context(context)

    case OpsService.run(mode, actor) do
      {:ok, result} ->
        {:ok, %{result: result.message, data: result}}

      {:error, :unauthorized} ->
        {:ok, %{result: "You are not authorized to run ContentOps operations from chat.", error: :unauthorized}}

      {:error, :mutations_disabled} ->
        {:ok, %{result: "Chat mutation tools are disabled in this environment.", error: :mutations_disabled}}

      {:error, :already_running} ->
        {:ok, %{result: "ContentOps is already running. Wait for the current run to finish.", error: :already_running}}

      {:error, :orchestrator_unavailable} ->
        {:ok, %{result: "ContentOps orchestrator is unavailable right now.", error: :orchestrator_unavailable}}

      {:error, reason} ->
        {:ok, %{result: "Failed to start run: #{inspect(reason)}", error: inspect(reason)}}
    end
  end
end
