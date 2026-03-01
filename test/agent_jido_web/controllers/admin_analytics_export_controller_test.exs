defmodule AgentJidoWeb.AdminAnalyticsExportControllerTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures

  alias AgentJido.Accounts.Scope
  alias AgentJido.Analytics
  alias AgentJido.QueryLogs

  test "requires authentication", %{conn: conn} do
    conn = get(conn, "/dashboard/analytics/export/gaps.csv")
    assert redirected_to(conn) == "/users/log-in"
  end

  test "returns CSV for admins", %{conn: conn} do
    admin = admin_user_fixture()
    actor = user_fixture()
    scope = Scope.for_user(actor)
    conn = log_in_user(conn, admin)

    identity = %{visitor_id: "csv-visitor", session_id: "csv-session", path: "/search", referrer_host: "jido.run"}

    {:ok, query_log} =
      QueryLogs.create_query_log(scope, identity, %{
        source: "content_assistant",
        channel: "content_assistant_page",
        query: "agent retries",
        status: "no_results"
      })

    Analytics.track_feedback_safe(scope, %{
      event: "feedback_submitted",
      source: "content_assistant",
      channel: "content_assistant_no_results",
      path: "/search",
      feedback_value: "not_helpful",
      feedback_note: "No retries docs",
      query_log_id: query_log.id,
      visitor_id: "csv-visitor",
      session_id: "csv-session",
      metadata: %{surface: "content_assistant"}
    })

    gaps_conn = get(conn, "/dashboard/analytics/export/gaps.csv?days=30")
    assert get_resp_header(gaps_conn, "content-type") |> List.first() =~ "text/csv"
    assert gaps_conn.resp_body =~ "query_hash"

    feedback_conn = get(conn, "/dashboard/analytics/export/feedback.csv?days=30")
    assert get_resp_header(feedback_conn, "content-type") |> List.first() =~ "text/csv"
    assert feedback_conn.resp_body =~ "feedback_value"
  end
end
