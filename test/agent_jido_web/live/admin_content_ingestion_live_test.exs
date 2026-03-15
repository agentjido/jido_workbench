defmodule AgentJidoWeb.AdminContentIngestionLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  alias AgentJido.ContentIngest.Inventory

  defmodule ContentIngestStub do
    def sync(opts) do
      dry_run? = Keyword.get(opts, :dry_run, false)
      selected_sources = Keyword.get(opts, :sources, [])

      if selected_sources != [] and Keyword.get(opts, :reconcile_stale, true) do
        raise "targeted ingest must set reconcile_stale: false"
      end

      total_sources = if selected_sources == [], do: 12, else: length(selected_sources)

      %{
        mode: if(dry_run?, do: :dry_run, else: :apply),
        dry_run: dry_run?,
        total_sources: total_sources,
        inserted: if(selected_sources == [], do: 3, else: total_sources),
        updated: if(selected_sources == [], do: 2, else: 0),
        skipped: if(selected_sources == [], do: 7, else: 0),
        deleted: if(selected_sources == [], do: 1, else: 0),
        failed: [],
        failed_count: 0
      }
    end
  end

  defmodule ContentAuditStub do
    @issue_order [
      :missing,
      :orphaned,
      :collection_mismatch,
      :stale_hash,
      :duplicate_source_id,
      :errored_or_unchunked
    ]

    def audit(opts) do
      sources =
        opts
        |> Keyword.get(:sources, [])
        |> Enum.sort_by(&{&1.collection, &1.source_id})

      expected = Enum.map(sources, &expected_from_source/1)

      rows =
        expected
        |> Enum.with_index()
        |> Enum.map(fn {source, idx} -> row_for_index(source, idx) end)
        |> maybe_append_orphaned_row(sources)

      ingested =
        rows
        |> Enum.map(& &1.ingested)
        |> Enum.reject(&is_nil/1)

      %{
        expected: expected,
        ingested: ingested,
        rows: rows,
        summary: summary(rows, expected, ingested)
      }
    end

    defp row_for_index(source, 0) do
      stale_hash =
        case source.content_hash do
          value when is_binary(value) and value != "" -> "#{value}:stale"
          _other -> "stale-hash"
        end

      %{
        source_id: source.source_id,
        status: :stale_hash,
        issues: [:stale_hash],
        expected: source,
        ingested: ingested_from_source(source, stale_hash)
      }
    end

    defp row_for_index(source, 1) do
      %{
        source_id: source.source_id,
        status: :missing,
        issues: [:missing],
        expected: source,
        ingested: nil
      }
    end

    defp row_for_index(source, _idx) do
      %{
        source_id: source.source_id,
        status: :ok,
        issues: [],
        expected: source,
        ingested: ingested_from_source(source, source.content_hash)
      }
    end

    defp maybe_append_orphaned_row(rows, []), do: rows

    defp maybe_append_orphaned_row(rows, _sources) do
      rows ++
        [
          %{
            source_id: "orphan:legacy",
            status: :orphaned,
            issues: [:orphaned],
            expected: nil,
            ingested:
              ingested_from_source(
                %{
                  source_id: "orphan:legacy",
                  collection: "site_blog",
                  content_hash: "orphan-hash",
                  title: "Legacy orphan",
                  path: "/legacy/orphan",
                  metadata: %{"content_hash" => "orphan-hash", "title" => "Legacy orphan", "path" => "/legacy/orphan"}
                },
                "orphan-hash"
              )
          }
        ]
    end

    defp expected_from_source(source) do
      metadata = source.metadata || %{}

      %{
        source_id: source.source_id,
        collection: source.collection,
        content_hash: Map.get(metadata, "content_hash"),
        title: Map.get(metadata, "title") || Map.get(metadata, "name"),
        path: Map.get(metadata, "path") || Map.get(metadata, "url"),
        metadata: metadata
      }
    end

    defp ingested_from_source(source, content_hash) do
      metadata = Map.put(source.metadata || %{}, "content_hash", content_hash)

      %{
        source_id: source.source_id,
        collection: source.collection,
        document_id: Ecto.UUID.generate(),
        content_hash: content_hash,
        title: source.title,
        path: source.path,
        metadata: metadata,
        document_status: "indexed",
        document_error: nil,
        declared_chunk_count: 1,
        actual_chunk_count: 1,
        updated_at: DateTime.utc_now(),
        duplicate_count: 0,
        duplicate_document_ids: []
      }
    end

    defp summary(rows, expected, ingested) do
      issue_counts =
        Enum.reduce(@issue_order, %{}, fn issue, acc ->
          count = Enum.count(rows, &Enum.member?(&1.issues || [], issue))
          Map.put(acc, issue, count)
        end)

      status_counts =
        [:ok | @issue_order]
        |> Enum.map(&{&1, 0})
        |> Map.new()
        |> Map.merge(Enum.frequencies_by(rows, & &1.status))

      ok_count = Map.get(status_counts, :ok, 0)

      %{
        expected_count: length(expected),
        ingested_count: length(ingested),
        compared_count: length(rows),
        ok_count: ok_count,
        blocking_count: length(rows) - ok_count,
        issue_counts: issue_counts,
        status_counts: status_counts
      }
    end
  end

  setup %{conn: conn} do
    original_ingest_module = Application.get_env(:agent_jido, :dashboard_ingest_module)
    original_audit_module = Application.get_env(:agent_jido, :dashboard_content_audit_module)

    Application.put_env(:agent_jido, :dashboard_ingest_module, ContentIngestStub)
    Application.put_env(:agent_jido, :dashboard_content_audit_module, ContentAuditStub)

    admin_conn = log_in_user(conn, admin_user_fixture())

    on_exit(fn ->
      if original_ingest_module do
        Application.put_env(:agent_jido, :dashboard_ingest_module, original_ingest_module)
      else
        Application.delete_env(:agent_jido, :dashboard_ingest_module)
      end

      if original_audit_module do
        Application.put_env(:agent_jido, :dashboard_content_audit_module, original_audit_module)
      else
        Application.delete_env(:agent_jido, :dashboard_content_audit_module)
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

  test "renders unified status page and actions", %{admin_conn: admin_conn} do
    {:ok, view, html} = live(admin_conn, "/dashboard/content-ingestion")

    assert has_element?(view, "#admin-shell")
    assert has_element?(view, "a[data-admin-nav-path='/dashboard/content-ingestion'][data-admin-nav-active='true']", "Content Ingestion")
    refute has_element?(view, "a[data-admin-nav-path='/dashboard/content-ingestion/audit']")
    assert html =~ "Content Ingestion Status"
    assert html =~ "Current state"
    assert html =~ "Source status"
    assert has_element?(view, "button[phx-click='refresh_status']", "Refresh status")
    assert has_element?(view, "button[phx-click='ingest_needs_refresh']", "Ingest needs refresh")
    assert has_element?(view, "button[phx-click='ingest_all']", "Ingest all")
  end

  test "ingest needs refresh shows summary", %{admin_conn: admin_conn} do
    sources_count = Inventory.build() |> Enum.count()
    expected_sources = min(sources_count, 2)

    assert expected_sources > 0

    {:ok, view, _html} = live(admin_conn, "/dashboard/content-ingestion")

    view
    |> element("button[phx-click='ingest_needs_refresh']")
    |> render_click()

    assert_eventually(fn ->
      html = render(view)
      html =~ "Last run: Ingest needs refresh" and html =~ "sources: #{expected_sources}"
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
