defmodule AgentJidoWeb.NavSearchModalComponent do
  @moduledoc """
  Global primary-nav search modal with full in-modal results.
  """
  use AgentJidoWeb, :live_component

  alias AgentJido.Analytics
  alias AgentJido.QueryLogs
  alias AgentJido.Search
  alias AgentJido.Search.Result
  alias Phoenix.LiveView.JS

  @default_limit 10

  @type search_status :: :idle | :loading | :results | :empty | :error

  @impl true
  @spec update(map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(assigns, socket) do
    socket =
      socket
      |> assign_new(:query, fn -> "" end)
      |> assign_new(:status, fn -> :idle end)
      |> assign_new(:results, fn -> [] end)
      |> assign_new(:search_ref, fn -> nil end)
      |> assign_new(:query_log_id, fn -> nil end)
      |> assign_new(:last_query_log_id, fn -> nil end)
      |> assign_new(:search_started_at, fn -> nil end)
      |> assign_new(:feedback_note, fn -> "" end)
      |> assign_new(:feedback_submitted, fn -> false end)
      |> assign_new(:current_scope, fn -> nil end)
      |> assign_new(:analytics_identity, fn -> %{visitor_id: nil, session_id: nil, referrer_host: nil} end)
      |> assign(Map.drop(assigns, [:search_complete]))
      |> maybe_apply_search_complete(assigns)

    {:ok, socket}
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("search", %{"search" => %{"q" => raw_query}}, socket) do
    query = normalize_query(raw_query)

    if query == "" do
      {:noreply,
       assign(socket,
         query: "",
         status: :idle,
         results: [],
         search_ref: nil,
         query_log_id: nil,
         last_query_log_id: nil,
         search_started_at: nil,
         feedback_note: "",
         feedback_submitted: false
       )}
    else
      search_ref = System.unique_integer([:positive, :monotonic])
      component_id = socket.assigns.id
      live_view_pid = socket.root_pid || self()
      query_log_id = track_query_id(query, socket)
      started_at = System.monotonic_time()
      search_module = search_module()

      Task.start(fn ->
        response = run_search(search_module, query)
        send_update(live_view_pid, __MODULE__, id: component_id, search_complete: {search_ref, query, response})
      end)

      {:noreply,
       assign(socket,
         query: query,
         status: :loading,
         results: [],
         search_ref: search_ref,
         query_log_id: query_log_id,
         last_query_log_id: nil,
         search_started_at: started_at,
         feedback_note: "",
         feedback_submitted: false
       )}
    end
  end

  def handle_event("result_click", params, socket) do
    rank = normalize_rank(Map.get(params, "rank"))
    target_url = normalize_query(Map.get(params, "url"))

    analytics_module().track_event_safe(socket.assigns.current_scope, %{
      event: "search_result_clicked",
      source: "search",
      channel: "nav_modal",
      path: socket.assigns.analytics_identity[:path] || "/",
      target_url: target_url,
      rank: rank,
      query_log_id: socket.assigns.last_query_log_id,
      visitor_id: socket.assigns.analytics_identity[:visitor_id],
      session_id: socket.assigns.analytics_identity[:session_id],
      metadata: %{surface: "search_modal"}
    })

    {:noreply, socket}
  end

  def handle_event("submit_feedback", %{"feedback" => feedback_params}, socket) do
    feedback_note = normalize_feedback_note(Map.get(feedback_params, "note"))

    analytics_module().track_feedback_safe(socket.assigns.current_scope, %{
      event: "feedback_submitted",
      source: "search",
      channel: "nav_modal_no_results",
      path: socket.assigns.analytics_identity[:path] || "/",
      feedback_value: "not_helpful",
      feedback_note: feedback_note,
      query_log_id: socket.assigns.last_query_log_id,
      visitor_id: socket.assigns.analytics_identity[:visitor_id],
      session_id: socket.assigns.analytics_identity[:session_id],
      metadata: %{surface: "search"}
    })

    {:noreply, assign(socket, feedback_note: "", feedback_submitted: true)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     assign(socket,
       query: "",
       status: :idle,
       results: [],
       search_ref: nil,
       query_log_id: nil,
       last_query_log_id: nil,
       search_started_at: nil,
       feedback_note: "",
       feedback_submitted: false
     )}
  end

  @impl true
  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id={"#{@id}-root"}>
      <.phx_modal id={@id} on_cancel={JS.push("reset", target: @myself)}>
        <:title>Search</:title>
        <:subtitle>Find docs, blog posts, and ecosystem packages.</:subtitle>

        <div class="mt-6 space-y-4">
          <.form for={%{}} as={:search} phx-submit="search" phx-target={@myself}>
            <div class="flex flex-col gap-3 sm:flex-row">
              <input
                id={"#{@id}-input"}
                name="search[q]"
                type="search"
                value={@query}
                placeholder="Search Jido content..."
                class="w-full rounded-xl border border-border bg-background px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/25"
                autocomplete="off"
              />
              <button
                type="submit"
                class="rounded-xl bg-primary px-5 py-3 text-sm font-semibold text-primary-foreground transition hover:bg-primary/90"
              >
                Search
              </button>
            </div>
          </.form>

          <div :if={@status == :idle} id={"#{@id}-idle"} class="text-sm text-muted-foreground">
            Enter a query and press Search.
          </div>

          <div
            :if={@status == :loading}
            id={"#{@id}-loading"}
            class="rounded-xl border border-border bg-background/70 p-4"
          >
            <div class="flex items-center gap-2 text-sm text-foreground">
              <.icon name="hero-arrow-path" class="h-4 w-4 animate-spin text-primary" />
              <span>Searching for "<span class="font-semibold">{@query}</span>"...</span>
            </div>
            <div class="mt-3 space-y-2">
              <div class="h-2 w-full rounded bg-primary/20 animate-pulse"></div>
              <div class="h-2 w-5/6 rounded bg-primary/15 animate-pulse"></div>
              <div class="h-2 w-2/3 rounded bg-primary/10 animate-pulse"></div>
            </div>
          </div>

          <div :if={@status == :results} id={"#{@id}-results"} class="space-y-3">
            <p class="text-xs text-muted-foreground">
              {length(@results)} result{if length(@results) == 1, do: "", else: "s"}
            </p>

            <div class="max-h-[52vh] overflow-y-auto pr-1 space-y-3">
              <%= for {result, rank} <- Enum.with_index(@results, 1) do %>
                <a
                  href={result.url}
                  phx-click={JS.push("result_click", target: @myself, value: %{url: result.url, rank: rank}) |> hide_modal(@id)}
                  class="block rounded-xl border border-border bg-background/70 p-4 transition hover:border-primary/50"
                >
                  <div class="mb-2 flex items-center justify-between gap-2">
                    <p class="text-xs font-semibold uppercase tracking-wide text-primary">
                      {result_source_label(result)}
                    </p>
                    <span class="text-[11px] text-muted-foreground">Open</span>
                  </div>
                  <h3 class="text-sm font-semibold text-foreground">{result.title}</h3>
                  <p class="mt-2 text-xs leading-relaxed text-muted-foreground">{result.snippet}</p>
                </a>
              <% end %>
            </div>
          </div>

          <div :if={@status == :empty} id={"#{@id}-empty"} class="space-y-3 text-sm text-muted-foreground">
            <p>No results found for "<span class="font-semibold">{@query}</span>".</p>

            <.form for={%{}} as={:feedback} phx-submit="submit_feedback" phx-target={@myself} class="space-y-2">
              <textarea
                name="feedback[note]"
                rows="2"
                maxlength="500"
                placeholder="Optional: what were you trying to find?"
                class="w-full resize-y rounded border border-border bg-background px-3 py-2 text-xs text-foreground placeholder:text-muted-foreground"
              >{@feedback_note}</textarea>
              <button
                type="submit"
                class="rounded-md border border-border bg-background px-3 py-1.5 text-xs font-semibold text-foreground hover:border-primary/50"
              >
                Submit feedback
              </button>
            </.form>

            <p :if={@feedback_submitted} class="text-xs font-semibold text-emerald-300">
              Thanks. We logged this search gap.
            </p>
          </div>

          <div :if={@status == :error} id={"#{@id}-error"} class="text-sm text-destructive">
            Search is temporarily unavailable right now. Please try again in a moment.
          </div>
        </div>
      </.phx_modal>
    </div>
    """
  end

  @spec maybe_apply_search_complete(Phoenix.LiveView.Socket.t(), map()) :: Phoenix.LiveView.Socket.t()
  defp maybe_apply_search_complete(socket, %{search_complete: {search_ref, query, response}}) do
    if socket.assigns.search_ref == search_ref do
      apply_search_response(socket, query, response)
    else
      socket
    end
  end

  defp maybe_apply_search_complete(socket, _assigns), do: socket

  @spec apply_search_response(Phoenix.LiveView.Socket.t(), String.t(), term()) :: Phoenix.LiveView.Socket.t()
  defp apply_search_response(socket, query, {:ok, results, status}) when is_list(results) do
    latency_ms = query_latency_ms(socket.assigns.search_started_at)

    cond do
      results != [] ->
        finalize_query_log(socket.assigns.query_log_id, "success", length(results), latency_ms)

        assign(socket,
          query: query,
          status: :results,
          results: results,
          search_ref: nil,
          query_log_id: nil,
          last_query_log_id: socket.assigns.query_log_id,
          search_started_at: nil
        )

      status == :success ->
        finalize_query_log(socket.assigns.query_log_id, "no_results", 0, latency_ms)

        assign(socket,
          query: query,
          status: :empty,
          results: [],
          search_ref: nil,
          query_log_id: nil,
          last_query_log_id: socket.assigns.query_log_id,
          search_started_at: nil
        )

      true ->
        finalize_query_log(socket.assigns.query_log_id, "error", 0, latency_ms)

        assign(socket,
          query: query,
          status: :error,
          results: [],
          search_ref: nil,
          query_log_id: nil,
          last_query_log_id: socket.assigns.query_log_id,
          search_started_at: nil
        )
    end
  end

  defp apply_search_response(socket, query, {:ok, results}) when is_list(results) do
    latency_ms = query_latency_ms(socket.assigns.search_started_at)

    if results == [] do
      finalize_query_log(socket.assigns.query_log_id, "no_results", 0, latency_ms)

      assign(socket,
        query: query,
        status: :empty,
        results: [],
        search_ref: nil,
        query_log_id: nil,
        last_query_log_id: socket.assigns.query_log_id,
        search_started_at: nil
      )
    else
      finalize_query_log(socket.assigns.query_log_id, "success", length(results), latency_ms)

      assign(socket,
        query: query,
        status: :results,
        results: results,
        search_ref: nil,
        query_log_id: nil,
        last_query_log_id: socket.assigns.query_log_id,
        search_started_at: nil
      )
    end
  end

  defp apply_search_response(socket, query, _response) do
    latency_ms = query_latency_ms(socket.assigns.search_started_at)
    finalize_query_log(socket.assigns.query_log_id, "error", 0, latency_ms)

    assign(socket,
      query: query,
      status: :error,
      results: [],
      search_ref: nil,
      query_log_id: nil,
      last_query_log_id: socket.assigns.query_log_id,
      search_started_at: nil
    )
  end

  @spec result_source_label(Result.t()) :: String.t()
  defp result_source_label(%Result{source_type: :docs}), do: "Docs"
  defp result_source_label(%Result{source_type: :blog}), do: "Blog"
  defp result_source_label(%Result{source_type: :ecosystem}), do: "Ecosystem"
  defp result_source_label(_), do: "Result"

  @spec normalize_query(term()) :: String.t()
  defp normalize_query(query) when is_binary(query), do: String.trim(query)
  defp normalize_query(_query), do: ""

  defp normalize_feedback_note(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.slice(0, 500)
  end

  defp normalize_feedback_note(_value), do: nil

  defp normalize_rank(value) when is_integer(value) and value > 0, do: value

  defp normalize_rank(value) when is_binary(value) do
    case Integer.parse(value) do
      {rank, ""} when rank > 0 -> rank
      _ -> nil
    end
  end

  defp normalize_rank(_value), do: nil

  defp run_search(search_module, query) do
    cond do
      function_exported?(search_module, :query_with_status, 2) ->
        search_module.query_with_status(query, limit: @default_limit)

      function_exported?(search_module, :query, 2) ->
        case search_module.query(query, limit: @default_limit) do
          {:ok, rows} when is_list(rows) -> {:ok, rows, :success}
          other -> other
        end

      true ->
        {:error, :invalid_search_module}
    end
  end

  defp track_query_id(query, socket) when is_binary(query) do
    query_log_id =
      case QueryLogs.track_query_safe(socket.assigns.current_scope, socket.assigns.analytics_identity, %{
             source: "search",
             channel: "nav_modal",
             query: query,
             status: "submitted",
             path: socket.assigns.analytics_identity[:path],
             referrer_host: socket.assigns.analytics_identity[:referrer_host],
             metadata: %{surface: "primary_nav"}
           }) do
        %{id: id} -> id
        _ -> nil
      end

    analytics_module().track_event_safe(socket.assigns.current_scope, %{
      event: "search_submitted",
      source: "search",
      channel: "nav_modal",
      path: socket.assigns.analytics_identity[:path] || "/",
      query_log_id: query_log_id,
      visitor_id: socket.assigns.analytics_identity[:visitor_id],
      session_id: socket.assigns.analytics_identity[:session_id],
      metadata: %{surface: "primary_nav", query: query}
    })

    query_log_id
  end

  defp finalize_query_log(query_log_id, status, results_count, latency_ms)
       when is_binary(status) and is_integer(results_count) do
    QueryLogs.finalize_query_safe(query_log_id, %{
      status: status,
      results_count: max(results_count, 0),
      latency_ms: max(latency_ms, 0)
    })
  end

  defp query_latency_ms(started_at) when is_integer(started_at) do
    System.monotonic_time()
    |> Kernel.-(started_at)
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp query_latency_ms(_started_at), do: 0

  defp analytics_module do
    Application.get_env(:agent_jido, :analytics_module, Analytics)
  end

  defp search_module do
    Application.get_env(:agent_jido, :nav_search_module, Search)
  end
end
