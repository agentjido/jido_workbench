defmodule AgentJidoWeb.AdminContentIngestionLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  alias AgentJido.ContentIngest.Inventory

  defmodule ContentIngestStub do
    def sync(opts) do
      dry_run? = Keyword.get(opts, :dry_run, false)
      single_source? = length(Keyword.get(opts, :sources, [])) == 1

      if single_source? and Keyword.get(opts, :reconcile_stale, true) do
        raise "single-source ingest must set reconcile_stale: false"
      end

      cond do
        dry_run? ->
          %{
            mode: :dry_run,
            dry_run: true,
            total_sources: 12,
            inserted: 2,
            updated: 1,
            skipped: 9,
            deleted: 0,
            failed: [],
            failed_count: 0
          }

        single_source? ->
          %{
            mode: :apply,
            dry_run: false,
            total_sources: 1,
            inserted: 1,
            updated: 0,
            skipped: 0,
            deleted: 0,
            failed: [],
            failed_count: 0
          }

        true ->
          %{
            mode: :apply,
            dry_run: false,
            total_sources: 12,
            inserted: 3,
            updated: 2,
            skipped: 7,
            deleted: 1,
            failed: [],
            failed_count: 0
          }
      end
    end
  end

  setup %{conn: conn} do
    original_ingest_module = Application.get_env(:agent_jido, :dashboard_ingest_module)
    Application.put_env(:agent_jido, :dashboard_ingest_module, ContentIngestStub)

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
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, "/dashboard/content-ingestion")
  end

  test "blocks authenticated non-admin users", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/dashboard/content-ingestion")
  end

  test "renders inventory list and action buttons", %{admin_conn: admin_conn} do
    {:ok, view, html} = live(admin_conn, "/dashboard/content-ingestion")

    assert has_element?(view, "#admin-shell")
    assert has_element?(view, "a[data-admin-nav-path='/dashboard/content-ingestion'][data-admin-nav-active='true']", "Content Ingestion")
    assert html =~ "Content Ingestion"
    assert html =~ "Local Content Inventory"
    assert has_element?(view, "button[phx-click='refresh_sources']", "Refresh inventory")
    assert has_element?(view, "button[phx-click='preview_all']", "Preview ingest all")
    assert has_element?(view, "button[phx-click='ingest_all']", "Ingest all")
    assert has_element?(view, "button[phx-click='ingest_source']", "Re-ingest")
  end

  test "preview all shows summary", %{admin_conn: admin_conn} do
    {:ok, view, _html} = live(admin_conn, "/dashboard/content-ingestion")

    view
    |> element("button[phx-click='preview_all']")
    |> render_click()

    assert_eventually(fn ->
      html = render(view)
      html =~ "Last run: Preview all sources" and html =~ "inserted: 2" and html =~ "Run completed successfully"
    end)
  end

  test "ingest all shows summary", %{admin_conn: admin_conn} do
    {:ok, view, _html} = live(admin_conn, "/dashboard/content-ingestion")

    view
    |> element("button[phx-click='ingest_all']")
    |> render_click()

    assert_eventually(fn ->
      html = render(view)
      html =~ "Last run: Ingest all sources" and html =~ "deleted: 1" and html =~ "Run completed successfully"
    end)
  end

  test "single source ingest works", %{admin_conn: admin_conn} do
    source =
      Inventory.build()
      |> Enum.sort_by(&{&1.collection, &1.source_id})
      |> List.first()

    assert source

    {:ok, view, _html} = live(admin_conn, "/dashboard/content-ingestion")

    view
    |> element("button[phx-click='ingest_source'][phx-value-source-id='#{source.source_id}']")
    |> render_click()

    assert_eventually(fn ->
      html = render(view)
      html =~ "Last run: Re-ingest #{source.source_id}" and html =~ "sources: 1" and html =~ "inserted: 1"
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
