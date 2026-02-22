defmodule AgentJidoWeb.NavSearchModalComponentTest do
  use AgentJidoWeb.ConnCase, async: false

  import Ecto.Query
  import Phoenix.LiveViewTest

  alias AgentJido.Analytics.AnalyticsEvent
  alias AgentJido.Search.Result

  defmodule SearchStub do
    def query_with_status("agents", _opts) do
      {:ok,
       [
         %Result{
           title: "Agents",
           snippet: "Agents docs",
           url: "/docs/concepts/agents",
           source_type: :docs,
           score: 0.9
         }
       ], :success}
    end

    def query_with_status("none", _opts), do: {:ok, [], :success}
    def query_with_status(_query, _opts), do: {:error, :unavailable}
  end

  defmodule ModalHarnessLive do
    use AgentJidoWeb, :live_view

    @impl true
    def render(assigns) do
      ~H"""
      <.live_component
        module={AgentJidoWeb.NavSearchModalComponent}
        id="primary-nav-search-modal"
        analytics_identity={
          %{
            visitor_id: "search-test-visitor",
            session_id: "search-test-session",
            path: "/docs/concepts/agents",
            referrer_host: "agentjido.xyz"
          }
        }
      />
      """
    end
  end

  setup do
    original_search_module = Application.get_env(:agent_jido, :nav_search_module)
    Application.put_env(:agent_jido, :nav_search_module, SearchStub)

    on_exit(fn ->
      if original_search_module do
        Application.put_env(:agent_jido, :nav_search_module, original_search_module)
      else
        Application.delete_env(:agent_jido, :nav_search_module)
      end
    end)

    :ok
  end

  test "tracks result click events", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='search']", search: %{q: "agents"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ ~s(id="primary-nav-search-modal-results")
    end)

    view
    |> element("a[href='/docs/concepts/agents']")
    |> render_click()

    assert_eventually(fn ->
      AgentJido.Repo.exists?(from(e in AnalyticsEvent, where: e.event == "search_result_clicked"))
    end)
  end

  test "tracks no-results feedback events", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='search']", search: %{q: "none"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ ~s(id="primary-nav-search-modal-empty")
    end)

    view
    |> form("form[phx-submit='submit_feedback']", feedback: %{note: "Need agent docs"})
    |> render_submit()

    assert_eventually(fn ->
      AgentJido.Repo.exists?(
        from(e in AnalyticsEvent,
          where:
            e.event == "feedback_submitted" and e.source == "search" and
              e.channel == "nav_modal_no_results"
        )
      )
    end)
  end

  defp assert_eventually(fun, attempts \\ 20)

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
