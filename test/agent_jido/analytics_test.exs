defmodule AgentJido.AnalyticsTest do
  use AgentJido.DataCase, async: false

  import AgentJido.AccountsFixtures

  alias AgentJido.Accounts.Scope
  alias AgentJido.Analytics
  alias AgentJido.Analytics.AnalyticsEvent
  alias AgentJido.Analytics.RateLimiter
  alias AgentJido.Analytics.Redactor
  alias AgentJido.QueryLogs
  alias AgentJido.Repo

  describe "redaction" do
    test "normalizes, redacts, and hashes query text" do
      raw = "  Contact me at mike@example.com and call +1 (555) 123-4567  "

      assert Redactor.normalize_query(raw) == "Contact me at mike@example.com and call +1 (555) 123-4567"

      redacted = Redactor.redact_query(raw)
      assert redacted =~ "[email]"
      assert redacted =~ "[phone]"

      hash = Redactor.query_hash(raw)
      assert is_binary(hash)
      assert byte_size(hash) == 64
      assert hash == Redactor.query_hash(raw)
    end
  end

  describe "event tracking" do
    test "tracks event with server-side user identity and preserves metadata" do
      user = user_fixture()
      scope = Scope.for_user(user)

      attrs = %{
        event: "code_copied",
        source: "docs",
        channel: "copy_button",
        path: "/docs/concepts/agents",
        visitor_id: "visitor-123456",
        session_id: "session-123456",
        metadata: %{surface: "docs_page"},
        user_id: Ecto.UUID.generate()
      }

      assert {:ok, %AnalyticsEvent{} = event} = Analytics.track_event(scope, attrs)
      assert event.user_id == user.id
      assert event.event == "code_copied"
      assert event.metadata["surface"] == "docs_page"
    end

    test "excludes admin-scoped analytics events" do
      admin = admin_user_fixture()
      scope = Scope.for_user(admin)
      before_count = Repo.aggregate(AnalyticsEvent, :count, :id)

      attrs = %{
        event: "code_copied",
        source: "docs",
        channel: "copy_button",
        path: "/docs/concepts/agents",
        visitor_id: "visitor-admin",
        session_id: "session-admin",
        metadata: %{surface: "docs_page"}
      }

      assert {:ok, :excluded_admin} = Analytics.track_event(scope, attrs)
      assert Repo.aggregate(AnalyticsEvent, :count, :id) == before_count
    end

    test "returns content gaps and reformulations in dashboard snapshot" do
      admin = admin_user_fixture()
      admin_scope = Scope.for_user(admin)
      actor = user_fixture()
      scope = Scope.for_user(actor)
      identity = %{visitor_id: "visitor-gap", session_id: "session-gap", path: "/docs", referrer_host: "agentjido.xyz"}

      {:ok, first} =
        QueryLogs.create_query_log(scope, identity, %{
          source: "content_assistant",
          channel: "content_assistant_page",
          query: "agent retries",
          status: "no_results"
        })

      QueryLogs.finalize_query_safe(first.id, %{status: "no_results", results_count: 0})

      {:ok, second} =
        QueryLogs.create_query_log(scope, identity, %{
          source: "content_assistant",
          channel: "content_assistant_page",
          query: "agent retry strategies",
          status: "success",
          results_count: 3
        })

      QueryLogs.finalize_query_safe(second.id, %{status: "success", results_count: 3})

      Analytics.track_feedback_safe(scope, %{
        event: "feedback_submitted",
        source: "content_assistant",
        channel: "content_assistant_no_results",
        path: "/search",
        feedback_value: "not_helpful",
        feedback_note: "I wanted retry docs",
        query_log_id: first.id,
        visitor_id: "visitor-gap",
        session_id: "session-gap",
        metadata: %{surface: "content_assistant"}
      })

      Analytics.track_feedback_safe(scope, %{
        event: "feedback_submitted",
        source: "content_assistant",
        channel: "content_assistant_modal",
        path: "/",
        feedback_value: "helpful",
        feedback_note: "Great summary",
        query_log_id: second.id,
        visitor_id: "visitor-gap",
        session_id: "session-gap",
        metadata: %{surface: "content_assistant"}
      })

      snapshot = Analytics.dashboard_snapshot(admin_scope, 7, top_limit: 5, gap_limit: 5, reform_limit: 5)

      assert snapshot.authorized?
      assert Enum.any?(snapshot.content_gaps, &(&1.query =~ "agent"))
      assert Enum.any?(snapshot.reformulations, &(&1.query == second.query))
      assert Enum.any?(snapshot.feedback_breakdown, &(&1.feedback_value == "not_helpful"))
      assert Enum.any?(snapshot.feedback_breakdown, &(&1.feedback_value == "helpful"))
      assert Enum.any?(snapshot.recent_feedback, &(&1.feedback_note == "I wanted retry docs"))
      assert Enum.any?(snapshot.recent_feedback, &(&1.feedback_note == "Great summary"))
    end

    test "rate limiter blocks after threshold" do
      RateLimiter.reset!()

      visitor_id = "visitor-rate"
      event = "code_copied"

      Enum.each(1..120, fn _ ->
        assert RateLimiter.allow?(visitor_id, event)
      end)

      refute RateLimiter.allow?(visitor_id, event)
    end
  end
end
