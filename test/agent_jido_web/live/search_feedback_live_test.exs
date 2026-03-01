defmodule AgentJidoWeb.ContentAssistantFeedbackLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import Ecto.Query
  import Phoenix.LiveViewTest

  alias AgentJido.Analytics.AnalyticsEvent
  alias AgentJido.ContentAssistant.Response

  defmodule ContentAssistantNoResultsStub do
    def respond(query, _opts) do
      {:ok,
       %Response{
         query: query,
         answer_markdown: "",
         answer_html: "",
         answer_mode: :no_results,
         citations: [],
         retrieval_status: :success,
         llm_attempted?: false,
         llm_enhanced?: false,
         enhancement_blocked_reason: :llm_unconfigured,
         query_log_id: nil
       }}
    end
  end

  test "tracks no-results feedback on ContentAssistantLive", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:content_assistant_module, ContentAssistantNoResultsStub)
      |> put_session(:assistant_opts, [])
      |> put_session(:analytics_identity, %{
        "visitor_id" => "content-assistant-live-visitor",
        "session_id" => "content-assistant-live-session",
        "path" => "/search"
      })

    {:ok, view, _html} = live(conn, "/search")

    view
    |> form("#content-assistant-form", assistant: %{q: "unknown-topic"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ ~s(id="content-assistant-no-results-state")
    end)

    assert has_element?(view, "#content-assistant-no-results-feedback button[title='Not helpful']")

    view
    |> form("#content-assistant-no-results-feedback-form", feedback: %{note: "Need a section on retries"})
    |> render_submit()

    assert_eventually(fn ->
      AgentJido.Repo.exists?(
        from(e in AnalyticsEvent,
          where:
            e.event == "feedback_submitted" and e.source == "content_assistant" and
              e.channel == "content_assistant_no_results"
        )
      )
    end)
  end

  defp assert_eventually(fun, attempts \\ 60)

  defp assert_eventually(fun, attempts) when attempts > 0 do
    if fun.() do
      :ok
    else
      Process.sleep(25)
      assert_eventually(fun, attempts - 1)
    end
  end

  defp assert_eventually(_fun, 0), do: flunk("expected condition to become true")
end
