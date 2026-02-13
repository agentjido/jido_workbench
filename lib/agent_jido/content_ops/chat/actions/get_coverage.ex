defmodule AgentJido.ContentOps.Chat.Actions.GetCoverage do
  @moduledoc """
  Read-only tool that returns content plan coverage summary.
  """

  use Jido.Action,
    name: "contentops_get_coverage",
    description: "Get content plan coverage summary",
    schema: Zoi.object(%{})

  @impl true
  def run(_params, _context) do
    report = AgentJido.ContentPlan.coverage_report()

    result =
      "Coverage total=#{report.total}, by_status=#{inspect(report.by_status)}, by_section=#{inspect(report.by_section)}"

    {:ok, %{result: result, coverage: report}}
  end
end
