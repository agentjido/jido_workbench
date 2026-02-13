defmodule AgentJido.ContentOps.Chat.Actions.GetStatus do
  @moduledoc """
  Read-only tool that returns orchestrator runtime status.
  """

  use Jido.Action,
    name: "contentops_get_status",
    description: "Get current orchestrator status and summary",
    schema: Zoi.object(%{})

  @server_name AgentJido.ContentOps.OrchestratorServer

  @impl true
  def run(_params, _context) do
    case Jido.AgentServer.status(@server_name) do
      {:ok, status} ->
        snapshot = status.snapshot || %{}
        raw_state = status.raw_state || %{}

        summary = %{
          status: snapshot.status,
          agent_id: status.agent_id,
          total_runs: Map.get(raw_state, :total_runs, 0),
          last_run_mode: Map.get(raw_state, :last_run_mode),
          last_run_at: Map.get(raw_state, :last_run_at)
        }

        {:ok,
         %{
           result: "Orchestrator status: #{summary.status}, total_runs=#{summary.total_runs}",
           summary: summary
         }}

      {:error, reason} ->
        {:ok, %{result: "Orchestrator status unavailable: #{inspect(reason)}", error: inspect(reason)}}
    end
  end
end
