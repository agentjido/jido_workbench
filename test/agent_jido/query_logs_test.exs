defmodule AgentJido.QueryLogsTest do
  use AgentJido.DataCase, async: true

  alias AgentJido.QueryLogs

  describe "query tracking" do
    test "creates and summarizes Ask AI and search logs" do
      baseline = QueryLogs.query_volume_summary(7)
      search_query = "otp supervision #{System.unique_integer([:positive, :monotonic])}"
      ask_query = "how does cmd/2 work? #{System.unique_integer([:positive, :monotonic])}"

      {:ok, _} =
        QueryLogs.create_query_log(%{
          source: "search",
          channel: "nav_modal",
          query: search_query,
          status: "success",
          results_count: 3
        })

      {:ok, _} =
        QueryLogs.create_query_log(%{
          source: "ask_ai",
          channel: "ask_ai_modal",
          query: ask_query,
          status: "no_results",
          results_count: 0
        })

      summary = QueryLogs.query_volume_summary(7)
      assert summary.total >= baseline.total + 2
      assert summary.search >= baseline.search + 1
      assert summary.ask_ai >= baseline.ask_ai + 1
      assert summary.success >= baseline.success + 1
      assert summary.no_results >= baseline.no_results + 1
    end

    test "returns top repeated queries in lookback window" do
      repeated_query = "agent runtime #{System.unique_integer([:positive, :monotonic])}"

      {:ok, _} =
        QueryLogs.create_query_log(%{
          source: "search",
          channel: "search_page",
          query: repeated_query,
          status: "success",
          results_count: 2
        })

      {:ok, _} =
        QueryLogs.create_query_log(%{
          source: "search",
          channel: "nav_modal",
          query: repeated_query,
          status: "success",
          results_count: 4
        })

      top_queries = QueryLogs.list_top_queries(7, 100)

      assert Enum.any?(top_queries, fn query ->
               query.query == repeated_query and query.count >= 2
             end)
    end
  end
end
