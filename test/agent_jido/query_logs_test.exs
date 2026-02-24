defmodule AgentJido.QueryLogsTest do
  use AgentJido.DataCase, async: true

  import AgentJido.AccountsFixtures

  alias AgentJido.Accounts.Scope
  alias AgentJido.QueryLogs

  describe "query tracking" do
    test "creates and summarizes content assistant logs" do
      baseline = QueryLogs.query_volume_summary(7)
      success_query = "otp supervision #{System.unique_integer([:positive, :monotonic])}"
      empty_query = "how does cmd/2 work? #{System.unique_integer([:positive, :monotonic])}"

      {:ok, _} =
        QueryLogs.create_query_log(%{
          source: "content_assistant",
          channel: "content_assistant_modal",
          query: success_query,
          status: "success",
          results_count: 3
        })

      {:ok, _} =
        QueryLogs.create_query_log(%{
          source: "content_assistant",
          channel: "content_assistant_page",
          query: empty_query,
          status: "no_results",
          results_count: 0
        })

      summary = QueryLogs.query_volume_summary(7)
      assert summary.total >= baseline.total + 2
      assert summary.content_assistant >= baseline.content_assistant + 2
      assert summary.success >= baseline.success + 1
      assert summary.no_results >= baseline.no_results + 1
    end

    test "returns top repeated queries in lookback window" do
      repeated_query = "agent runtime #{System.unique_integer([:positive, :monotonic])}"

      {:ok, _} =
        QueryLogs.create_query_log(%{
          source: "content_assistant",
          channel: "content_assistant_page",
          query: repeated_query,
          status: "success",
          results_count: 2
        })

      {:ok, _} =
        QueryLogs.create_query_log(%{
          source: "content_assistant",
          channel: "content_assistant_modal",
          query: repeated_query,
          status: "success",
          results_count: 4
        })

      top_queries = QueryLogs.list_top_queries(7, 100)

      assert Enum.any?(top_queries, fn query ->
               query.query == repeated_query and query.count >= 2
             end)
    end

    test "enriches query logs with identity and scope fields" do
      admin = admin_user_fixture()
      scope = Scope.for_user(admin)

      identity = %{
        visitor_id: "visitor-enriched",
        session_id: "session-enriched",
        path: "/docs/concepts/agents",
        referrer_host: "agentjido.xyz"
      }

      assert {:ok, query_log} =
               QueryLogs.create_query_log(scope, identity, %{
                 source: "content_assistant",
                 channel: "content_assistant_modal",
                 query: "Contact me at owner@example.com",
                 status: "submitted"
               })

      assert query_log.user_id == admin.id
      assert query_log.visitor_id == "visitor-enriched"
      assert query_log.session_id == "session-enriched"
      assert query_log.path == "/docs/concepts/agents"
      assert query_log.referrer_host == "agentjido.xyz"
      assert is_binary(query_log.query_hash)
      assert query_log.query =~ "[email]"
    end
  end
end
