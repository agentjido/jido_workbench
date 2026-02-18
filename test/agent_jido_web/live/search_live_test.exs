defmodule AgentJidoWeb.SearchLiveTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import Plug.Conn

  @endpoint AgentJidoWeb.Endpoint
  @query_issued_event [:agent_jido, :search, :query, :issued]
  @query_success_event [:agent_jido, :search, :query, :success]
  @query_failure_event [:agent_jido, :search, :query, :failure]

  defmodule SearchStub do
    @moduledoc false

    alias AgentJido.Search.Result

    @spec query(String.t(), keyword()) :: {:ok, [Result.t()]}
    def query(query, _opts \\ [])

    def query("arcana", _opts) do
      {:ok,
       [
         %Result{
           title: "Getting Started",
           snippet: "Kick off your first workflow.",
           url: "/docs/getting-started",
           source_type: :docs,
           score: 0.92
         },
         %Result{
           title: "Release Notes",
           snippet: "Highlights from this release.",
           url: "/blog/release-notes",
           source_type: :blog,
           score: 0.81
         },
         %Result{
           title: "Jido Core",
           snippet: "Main runtime package details.",
           url: "/ecosystem#jido-core",
           source_type: :ecosystem,
           score: 0.77
         }
       ]}
    end

    def query("slow", _opts) do
      Process.sleep(100)
      {:ok, []}
    end

    def query("backend-down", _opts), do: {:error, :arcana_unavailable}
    def query("raises", _opts), do: raise("arcana crashed")
    def query(_query, _opts), do: {:ok, []}
  end

  describe "/search" do
    test "is publicly routable and renders no-query state by default", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/search")

      assert html =~ "Search the site"
      assert html =~ ~s(id="search-no-query-state")
    end

    test "renders loading state while a query is running", %{conn: conn} do
      conn = with_search_stub(conn)
      {:ok, view, _html} = live(conn, "/search")

      loading_html =
        view
        |> form("#site-search-form", search: %{q: "slow"})
        |> render_submit()

      assert loading_html =~ ~s(id="search-loading-state")
      assert loading_html =~ "Searching for"
      assert_state(view, ~s(id="search-no-results-state"))
    end

    test "renders query results with source labels and destination links", %{conn: conn} do
      conn = with_search_stub(conn)
      {:ok, view, _html} = live(conn, "/search")

      view
      |> form("#site-search-form", search: %{q: "arcana"})
      |> render_submit()

      html = assert_state(view, ~s(id="search-results-state"))

      assert html =~ "Getting Started"
      assert html =~ "Release Notes"
      assert html =~ "Jido Core"
      assert html =~ "Docs"
      assert html =~ "Blog"
      assert html =~ "Ecosystem"
      assert html =~ ~s(href="/docs/getting-started")
      assert html =~ ~s(href="/blog/release-notes")
      assert html =~ ~s(href="/ecosystem#jido-core")
    end

    test "renders no-results state when query returns no matches", %{conn: conn} do
      conn = with_search_stub(conn)
      {:ok, view, _html} = live(conn, "/search")

      view
      |> form("#site-search-form", search: %{q: "missing"})
      |> render_submit()

      html = assert_state(view, ~s(id="search-no-results-state"))
      assert html =~ "No results found for"
      assert html =~ "missing"
    end

    test "renders explicit failure fallback messaging when backend search fails", %{conn: conn} do
      conn = with_search_stub(conn)
      {:ok, view, _html} = live(conn, "/search")

      view
      |> form("#site-search-form", search: %{q: "backend-down"})
      |> render_submit()

      html = assert_state(view, ~s(id="search-error-state"))

      assert html =~ "Search is temporarily unavailable right now."
    end

    test "emits issued and success telemetry for successful search flow", %{conn: conn} do
      attach_search_telemetry([@query_issued_event, @query_success_event])

      conn = with_search_stub(conn)
      {:ok, view, _html} = live(conn, "/search")

      view
      |> form("#site-search-form", search: %{q: "arcana"})
      |> render_submit()

      assert_receive {:search_telemetry, @query_issued_event, %{count: 1}, issued_meta}, 1_000
      assert issued_meta.query_length == 6

      assert_receive {:search_telemetry, @query_success_event, success_measurements, success_meta}, 1_000
      assert success_measurements.count == 1
      assert is_integer(success_measurements.latency_ms)
      assert success_measurements.latency_ms >= 0
      assert success_meta.query_length == 6
      assert success_meta.results_count == 3
      refute_receive {:search_telemetry, @query_failure_event, _, _}, 50
    end

    test "emits issued and failure telemetry for backend failure flow", %{conn: conn} do
      attach_search_telemetry([@query_issued_event, @query_failure_event])

      conn = with_search_stub(conn)
      {:ok, view, _html} = live(conn, "/search")

      view
      |> form("#site-search-form", search: %{q: "backend-down"})
      |> render_submit()

      assert_receive {:search_telemetry, @query_issued_event, %{count: 1}, issued_meta}, 1_000
      assert issued_meta.query_length == String.length("backend-down")

      assert_receive {:search_telemetry, @query_failure_event, failure_measurements, failure_meta}, 1_000
      assert failure_measurements.count == 1
      assert is_integer(failure_measurements.latency_ms)
      assert failure_measurements.latency_ms >= 0
      assert failure_meta.query_length == String.length("backend-down")
      refute_receive {:search_telemetry, @query_success_event, _, _}, 50
    end
  end

  describe "navigation entry points" do
    test "home header includes search in primary navigation", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(href="/search")
    end

    test "docs header includes search entry and search shortcut link", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/docs")
      assert html =~ ~s(href="/search")
      assert html =~ "Search..."
    end
  end

  setup_all do
    for app <- [:telemetry, :plug, :plug_crypto, :phoenix_pubsub] do
      {:ok, _started} = Application.ensure_all_started(app)
    end

    unless Process.whereis(AgentJido.PubSub) do
      start_supervised!({Phoenix.PubSub, name: AgentJido.PubSub})
    end

    unless Process.whereis(AgentJidoWeb.Endpoint) do
      start_supervised!(AgentJidoWeb.Endpoint)
    end

    :ok
  end

  setup do
    {:ok, conn: build_conn()}
  end

  defp with_search_stub(conn) do
    conn
    |> init_test_session(%{})
    |> put_session(:search_module, SearchStub)
  end

  defp attach_search_telemetry(events) do
    handler_id = "search-live-test-#{System.unique_integer([:positive, :monotonic])}"
    pid = self()

    :ok =
      :telemetry.attach_many(
        handler_id,
        events,
        fn event, measurements, metadata, _config ->
          send(pid, {:search_telemetry, event, measurements, metadata})
        end,
        nil
      )

    on_exit(fn ->
      :telemetry.detach(handler_id)
    end)

    :ok
  end

  defp assert_state(view, state_id_fragment, attempts \\ 40)

  defp assert_state(_view, state_id_fragment, 0) do
    flunk("expected to render state #{state_id_fragment}")
  end

  defp assert_state(view, state_id_fragment, attempts) do
    html = render(view)

    if html =~ state_id_fragment do
      html
    else
      Process.sleep(10)
      assert_state(view, state_id_fragment, attempts - 1)
    end
  end
end
