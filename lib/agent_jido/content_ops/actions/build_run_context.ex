defmodule AgentJido.ContentOps.Actions.BuildRunContext do
  @moduledoc """
  Creates a run context with a unique ID, mode, and timestamps.

  This is the first node in the orchestrator workflow. It establishes
  the run identity that all subsequent actions reference.
  """
  use Jido.Action,
    name: "contentops_build_run_context",
    description: "Creates a run context with run_id, mode, and timestamps",
    schema: [
      mode: [
        type: {:in, [:hourly, :nightly, :weekly, :monthly]},
        default: :hourly,
        doc: "Run cadence mode"
      ]
    ]

  @impl true
  def run(params, _context) do
    mode = Map.get(params, :mode, :hourly)

    {:ok,
     %{
       run_id: generate_run_id(),
       mode: mode,
       started_at: DateTime.utc_now(),
       status: :running
     }}
  end

  defp generate_run_id do
    "run_" <> Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
  end
end
