defmodule AgentJidoWeb.NavSearchModalComponent do
  @moduledoc """
  Global primary-nav search modal with full in-modal results.
  """
  use AgentJidoWeb, :live_component

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
      {:noreply, assign(socket, query: "", status: :idle, results: [], search_ref: nil, query_log_id: nil)}
    else
      search_ref = System.unique_integer([:positive, :monotonic])
      component_id = socket.assigns.id
      live_view_pid = socket.root_pid || self()
      query_log_id = track_query_id(query)

      Task.start(fn ->
        response = Search.query_with_status(query, limit: @default_limit)
        send_update(live_view_pid, __MODULE__, id: component_id, search_complete: {search_ref, query, response})
      end)

      {:noreply,
       assign(socket,
         query: query,
         status: :loading,
         results: [],
         search_ref: search_ref,
         query_log_id: query_log_id
       )}
    end
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, query: "", status: :idle, results: [], search_ref: nil, query_log_id: nil)}
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
              <%= for result <- @results do %>
                <a
                  href={result.url}
                  phx-click={hide_modal(@id)}
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

          <div :if={@status == :empty} id={"#{@id}-empty"} class="text-sm text-muted-foreground">
            No results found for "<span class="font-semibold">{@query}</span>".
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
    cond do
      results != [] ->
        finalize_query_log(socket.assigns.query_log_id, "success", length(results))
        assign(socket, query: query, status: :results, results: results, search_ref: nil, query_log_id: nil)

      status == :success ->
        finalize_query_log(socket.assigns.query_log_id, "no_results", 0)
        assign(socket, query: query, status: :empty, results: [], search_ref: nil, query_log_id: nil)

      true ->
        finalize_query_log(socket.assigns.query_log_id, "error", 0)
        assign(socket, query: query, status: :error, results: [], search_ref: nil, query_log_id: nil)
    end
  end

  defp apply_search_response(socket, query, {:ok, results}) when is_list(results) do
    if results == [] do
      finalize_query_log(socket.assigns.query_log_id, "no_results", 0)
      assign(socket, query: query, status: :empty, results: [], search_ref: nil, query_log_id: nil)
    else
      finalize_query_log(socket.assigns.query_log_id, "success", length(results))
      assign(socket, query: query, status: :results, results: results, search_ref: nil, query_log_id: nil)
    end
  end

  defp apply_search_response(socket, query, _response) do
    finalize_query_log(socket.assigns.query_log_id, "error", 0)
    assign(socket, query: query, status: :error, results: [], search_ref: nil, query_log_id: nil)
  end

  @spec result_source_label(Result.t()) :: String.t()
  defp result_source_label(%Result{source_type: :docs}), do: "Docs"
  defp result_source_label(%Result{source_type: :blog}), do: "Blog"
  defp result_source_label(%Result{source_type: :ecosystem}), do: "Ecosystem"
  defp result_source_label(_), do: "Result"

  @spec normalize_query(term()) :: String.t()
  defp normalize_query(query) when is_binary(query), do: String.trim(query)
  defp normalize_query(_query), do: ""

  defp track_query_id(query) when is_binary(query) do
    case QueryLogs.track_query_safe(%{
           source: "search",
           channel: "nav_modal",
           query: query,
           status: "submitted",
           metadata: %{surface: "primary_nav"}
         }) do
      %{id: id} -> id
      _ -> nil
    end
  end

  defp finalize_query_log(query_log_id, status, results_count)
       when is_binary(status) and is_integer(results_count) do
    QueryLogs.finalize_query_safe(query_log_id, %{
      status: status,
      results_count: max(results_count, 0)
    })
  end
end
