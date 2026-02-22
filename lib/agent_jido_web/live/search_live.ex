defmodule AgentJidoWeb.SearchLive do
  @moduledoc """
  Public LiveView for site-wide Arcana search.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.QueryLogs
  alias AgentJido.Search

  @telemetry_issued_event [:agent_jido, :search, :query, :issued]
  @telemetry_success_event [:agent_jido, :search, :query, :success]
  @telemetry_failure_event [:agent_jido, :search, :query, :failure]

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Search")
     |> assign(:query, "")
     |> assign(:results, [])
     |> assign(:status, :no_query)
     |> assign(:search_ref, nil)
     |> assign(:search_log_ids, %{})
     |> assign(:search_module, resolve_search_module(session))
     |> assign(:search_opts, resolve_search_opts(session))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-b from-background via-background to-primary/5 px-4 py-12 sm:px-6 lg:px-8">
      <div class="mx-auto w-full max-w-4xl">
        <section class="rounded-2xl border border-border bg-card p-6 shadow-sm sm:p-8">
          <p class="text-xs font-semibold uppercase tracking-[0.24em] text-muted-foreground">Arcana Search</p>
          <h1 class="mt-3 text-3xl font-semibold tracking-tight text-foreground sm:text-4xl">Search the site</h1>
          <p class="mt-3 text-sm text-muted-foreground sm:text-base">
            Find content across docs, blog posts, and the ecosystem directory.
          </p>

          <.form id="site-search-form" for={%{}} as={:search} phx-submit="search" class="mt-6 space-y-3">
            <label for="site-search-input" class="text-sm font-medium text-foreground">Search query</label>
            <div class="flex flex-col gap-3 sm:flex-row">
              <input
                id="site-search-input"
                name="search[q]"
                type="search"
                value={@query}
                placeholder="Search docs, blog, and ecosystem..."
                class="w-full rounded-xl border border-border bg-background px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/25"
              />
              <button
                type="submit"
                class="rounded-xl bg-primary px-5 py-3 text-sm font-semibold text-primary-foreground transition hover:bg-primary/90"
              >
                Search
              </button>
            </div>
          </.form>
        </section>

        <section
          :if={@status == :no_query}
          id="search-no-query-state"
          class="mt-6 rounded-2xl border border-dashed border-border bg-background/80 p-6 text-sm text-muted-foreground"
        >
          Enter a query to see site-wide search results.
        </section>

        <section
          :if={@status == :loading}
          id="search-loading-state"
          class="mt-6 rounded-2xl border border-border bg-card p-6 text-sm text-foreground"
        >
          Searching for "<span class="font-semibold">{@query}</span>"...
        </section>

        <section
          :if={@status == :results}
          id="search-results-state"
          class="mt-6 space-y-4"
        >
          <h2 class="text-lg font-semibold text-foreground">Results</h2>
          <ul class="space-y-3">
            <li :for={result <- @results} class="rounded-2xl border border-border bg-card p-5 shadow-sm">
              <div class="flex items-center justify-between gap-3">
                <p class="text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground">
                  {source_type_label(result.source_type)}
                </p>
                <a
                  href={result.url}
                  class="text-xs font-semibold uppercase tracking-[0.16em] text-primary hover:text-primary/80"
                >
                  Open result
                </a>
              </div>
              <h3 class="mt-3 text-lg font-semibold text-foreground">{result.title}</h3>
              <p class="mt-2 text-sm leading-6 text-muted-foreground">{result.snippet}</p>
            </li>
          </ul>
        </section>

        <section
          :if={@status == :no_results}
          id="search-no-results-state"
          class="mt-6 rounded-2xl border border-border bg-card p-6 text-sm text-muted-foreground"
        >
          No results found for "<span class="font-semibold text-foreground">{@query}</span>".
        </section>

        <section
          :if={@status == :error}
          id="search-error-state"
          class="mt-6 rounded-2xl border border-amber-400/40 bg-amber-100/30 p-6 text-sm text-foreground"
        >
          Search is temporarily unavailable right now. Please try again in a moment.
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("search", %{"search" => %{"q" => raw_query}}, socket) do
    query = normalize_query(raw_query)

    if query == "" do
      {:noreply, assign(socket, query: "", results: [], status: :no_query, search_ref: nil)}
    else
      search_ref = System.unique_integer([:monotonic, :positive])
      query_log_id = track_query_id(query)
      started_at = System.monotonic_time()
      emit_query_issued(query)
      send(self(), {:run_search, search_ref, query, started_at})

      search_log_ids =
        if query_log_id do
          Map.put(socket.assigns.search_log_ids, search_ref, query_log_id)
        else
          socket.assigns.search_log_ids
        end

      {:noreply, assign(socket, query: query, results: [], status: :loading, search_ref: search_ref, search_log_ids: search_log_ids)}
    end
  end

  @impl true
  def handle_info({:run_search, search_ref, query, started_at}, socket) do
    {outcome, results} = run_query(socket.assigns.search_module, query, socket.assigns.search_opts)
    {query_log_id, search_log_ids} = Map.pop(socket.assigns.search_log_ids, search_ref)
    latency_ms = query_latency_ms(started_at)
    emit_query_outcome(outcome, query, results, latency_ms)
    finalize_search_log(query_log_id, outcome, results)

    if socket.assigns.search_ref == search_ref do
      case outcome do
        :success ->
          status = if results == [], do: :no_results, else: :results
          {:noreply, assign(socket, status: status, results: results, search_ref: nil, search_log_ids: search_log_ids)}

        :failure ->
          {:noreply, assign(socket, status: :error, results: [], search_ref: nil, search_log_ids: search_log_ids)}
      end
    else
      {:noreply, assign(socket, :search_log_ids, search_log_ids)}
    end
  end

  defp run_query(search_module, query, opts) do
    response =
      if function_exported?(search_module, :query_with_status, 2) do
        search_module.query_with_status(query, opts)
      else
        search_module.query(query, opts)
      end

    case response do
      {:ok, results, status} when is_list(results) ->
        cond do
          results != [] -> {:success, results}
          status == :success -> {:success, []}
          true -> {:failure, []}
        end

      {:ok, results} when is_list(results) ->
        {:success, results}

      _ ->
        {:failure, []}
    end
  rescue
    _ -> {:failure, []}
  end

  defp resolve_search_module(session) do
    case Map.get(session, "search_module") do
      module when is_atom(module) and not is_nil(module) -> module
      _ -> Search
    end
  end

  defp resolve_search_opts(session) do
    case Map.get(session, "search_opts") do
      opts when is_list(opts) -> opts
      _ -> []
    end
  end

  defp normalize_query(query) when is_binary(query), do: String.trim(query)
  defp normalize_query(_query), do: ""

  defp track_query_id(query) when is_binary(query) do
    case QueryLogs.track_query_safe(%{
           source: "search",
           channel: "search_page",
           query: query,
           status: "submitted",
           metadata: %{surface: "search_live"}
         }) do
      %{id: id} -> id
      _ -> nil
    end
  end

  defp finalize_search_log(query_log_id, :success, results) when is_list(results) do
    QueryLogs.finalize_query_safe(query_log_id, %{
      status: if(results == [], do: "no_results", else: "success"),
      results_count: length(results)
    })
  end

  defp finalize_search_log(query_log_id, :failure, _results) do
    QueryLogs.finalize_query_safe(query_log_id, %{status: "error", results_count: 0})
  end

  defp query_latency_ms(started_at) when is_integer(started_at) do
    System.monotonic_time()
    |> Kernel.-(started_at)
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp query_latency_ms(_started_at), do: 0

  defp emit_query_issued(query) do
    :telemetry.execute(@telemetry_issued_event, %{count: 1}, %{query_length: String.length(query)})
  rescue
    _ -> :ok
  end

  defp emit_query_outcome(:success, query, results, latency_ms) do
    :telemetry.execute(
      @telemetry_success_event,
      %{count: 1, latency_ms: latency_ms},
      %{query_length: String.length(query), results_count: length(results)}
    )
  rescue
    _ -> :ok
  end

  defp emit_query_outcome(:failure, query, _results, latency_ms) do
    :telemetry.execute(
      @telemetry_failure_event,
      %{count: 1, latency_ms: latency_ms},
      %{query_length: String.length(query)}
    )
  rescue
    _ -> :ok
  end

  defp source_type_label(:docs), do: "Docs"
  defp source_type_label(:blog), do: "Blog"
  defp source_type_label(:ecosystem), do: "Ecosystem"
  defp source_type_label(source_type), do: source_type |> to_string() |> Phoenix.Naming.humanize()
end
