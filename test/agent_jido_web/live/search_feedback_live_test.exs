defmodule AgentJidoWeb.SearchFeedbackLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import Ecto.Query
  import Phoenix.LiveViewTest

  alias AgentJido.Analytics.AnalyticsEvent

  defmodule SearchNoResultsStub do
    def query(_query, _opts), do: {:ok, []}
  end

  test "tracks no-results feedback on SearchLive", %{conn: conn} do
    session = %{
      "search_module" => SearchNoResultsStub,
      "search_opts" => [],
      "analytics_identity" => %{
        "visitor_id" => "search-live-visitor",
        "session_id" => "search-live-session",
        "path" => "/search"
      }
    }

    {:ok, view, _html} = live_isolated(conn, AgentJidoWeb.SearchLive, session: session)

    view
    |> form("#site-search-form", search: %{q: "unknown-topic"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ ~s(id="search-no-results-state")
    end)

    view
    |> form("#search-no-results-feedback-form", feedback: %{note: "Need a section on retries"})
    |> render_submit()

    assert_eventually(fn ->
      AgentJido.Repo.exists?(
        from(e in AnalyticsEvent,
          where:
            e.event == "feedback_submitted" and e.source == "search" and
              e.channel == "search_page_no_results"
        )
      )
    end)
  end

  defp assert_eventually(fun, attempts \\ 30)

  defp assert_eventually(fun, attempts) when attempts > 0 do
    if fun.() do
      :ok
    else
      Process.sleep(20)
      assert_eventually(fun, attempts - 1)
    end
  end

  defp assert_eventually(_fun, 0), do: flunk("expected condition to become true")
end
