defmodule AgentJido.ContentOps.Chat.Actions.GetRecentRuns do
  @moduledoc """
  Read-only tool that returns recently completed ContentOps runs.
  """

  use Jido.Action,
    name: "contentops_get_recent_runs",
    description: "Get recent ContentOps run reports",
    schema:
      Zoi.object(%{
        limit:
          Zoi.integer(description: "How many recent runs to return")
          |> Zoi.default(5)
      })

  alias AgentJido.ContentOps.Chat.RunStore

  @impl true
  def run(%{limit: limit}, _context) do
    runs = RunStore.recent(limit)

    result =
      if runs == [] do
        "No recent runs recorded."
      else
        runs
        |> Enum.map_join("\n", fn run ->
          mode = run[:mode] || "unknown"
          run_id = run[:run_id] || "n/a"
          delivered = get_in(run, [:stats, :delivered]) || 0
          changes = get_in(run, [:stats, :change_requests]) || 0
          "- #{mode} #{run_id}: changes=#{changes}, delivered=#{delivered}"
        end)
      end

    {:ok, %{result: result, runs: runs}}
  end
end
