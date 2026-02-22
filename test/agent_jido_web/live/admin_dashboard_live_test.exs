defmodule AgentJidoWeb.AdminDashboardLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  alias AgentJido.QueryLogs

  defmodule DashboardIngestStub do
    def sync(opts) do
      dry_run? = Keyword.get(opts, :dry_run, false)
      single_source? = length(Keyword.get(opts, :sources, [])) == 1

      if single_source? and Keyword.get(opts, :reconcile_stale, true) do
        raise "single-source ingest must set reconcile_stale: false"
      end

      if dry_run? do
        %{
          mode: :dry_run,
          dry_run: true,
          total_sources: 7,
          inserted: 2,
          updated: 1,
          skipped: 4,
          deleted: 0,
          failed: [],
          failed_count: 0
        }
      else
        %{
          mode: :apply,
          dry_run: false,
          total_sources: if(single_source?, do: 1, else: 7),
          inserted: if(single_source?, do: 1, else: 2),
          updated: if(single_source?, do: 0, else: 1),
          skipped: if(single_source?, do: 0, else: 4),
          deleted: 0,
          failed: [],
          failed_count: 0
        }
      end
    end
  end

  setup %{conn: conn} do
    original_ingest_module = Application.get_env(:agent_jido, :dashboard_ingest_module)
    Application.put_env(:agent_jido, :dashboard_ingest_module, DashboardIngestStub)

    admin_conn = log_in_user(conn, admin_user_fixture())

    on_exit(fn ->
      if original_ingest_module do
        Application.put_env(:agent_jido, :dashboard_ingest_module, original_ingest_module)
      else
        Application.delete_env(:agent_jido, :dashboard_ingest_module)
      end
    end)

    %{admin_conn: admin_conn}
  end

  test "redirects unauthenticated users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, "/dashboard")
  end

  test "blocks authenticated non-admin users", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/dashboard")
  end

  test "renders admin control-plane links for authenticated admins", %{admin_conn: admin_conn} do
    {:ok, view, html} = live(admin_conn, "/dashboard")

    assert html =~ "Admin Control Plane"
    assert has_element?(view, "a[href='/arcana']", "Open Arcana dashboard")
    assert has_element?(view, "a[href='/dev/jido']", "Open Jido Studio")
    assert has_element?(view, "a[href='/dev/contentops']", "Open ContentOps dashboard")

    assert has_element?(
             view,
             "a[href='/dev/contentops/github']",
             "Open ContentOps GitHub dashboard"
           )

    assert has_element?(view, "a[href='/dashboard/content-generator']", "Open Content Generator")
    assert has_element?(view, "#dashboard-query-tracking", "Query Tracking")
    assert has_element?(view, "#dashboard-content-ingest", "Content Ingestion")
    assert has_element?(view, "button[phx-click='preview_ingest']", "Preview ingest changes")
    assert has_element?(view, "button[phx-click='run_ingest']", "Run ingest now")
    assert has_element?(view, "button[phx-click='run_ingest_one']", "Ingest 1")
  end

  test "shows tracked search and Ask AI queries", %{admin_conn: admin_conn} do
    {:ok, _} =
      QueryLogs.create_query_log(%{
        source: "search",
        channel: "nav_modal",
        query: "agent supervision",
        status: "success",
        results_count: 4
      })

    {:ok, _} =
      QueryLogs.create_query_log(%{
        source: "ask_ai",
        channel: "ask_ai_modal",
        query: "what is cmd/2?",
        status: "no_results",
        results_count: 0
      })

    {:ok, view, html} = live(admin_conn, "/dashboard")

    assert html =~ "Query Tracking"
    assert html =~ "agent supervision"
    assert html =~ "what is cmd/2?"
    assert has_element?(view, "button[phx-click='refresh_query_tracking']", "Refresh query logs")
  end

  test "preview suggests pending ingestion work", %{admin_conn: admin_conn} do
    {:ok, view, _html} = live(admin_conn, "/dashboard")

    view
    |> element("button[phx-click='preview_ingest']")
    |> render_click()

    assert_eventually(fn ->
      html = render(view)
      html =~ "Last preview" and html =~ "inserted: 2" and html =~ "Pending ingestion changes detected (3)"
    end)
  end

  test "apply ingestion reports completion summary", %{admin_conn: admin_conn} do
    {:ok, view, _html} = live(admin_conn, "/dashboard")

    view
    |> element("button[phx-click='run_ingest']")
    |> render_click()

    assert_eventually(fn ->
      html = render(view)
      html =~ "Last apply run" and html =~ "inserted: 2" and html =~ "Ingestion apply completed successfully."
    end)
  end

  test "single-source ingest applies exactly one source", %{admin_conn: admin_conn} do
    {:ok, view, _html} = live(admin_conn, "/dashboard")

    view
    |> element("button[phx-click='run_ingest_one']")
    |> render_click()

    assert_eventually(fn ->
      html = render(view)
      html =~ "Last apply run" and html =~ "sources: 1" and html =~ "inserted: 1"
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

  defp assert_eventually(_fun, 0) do
    flunk("expected condition to become true")
  end
end
