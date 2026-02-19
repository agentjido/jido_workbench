defmodule AgentJidoWeb.NavAskAiModalComponent do
  @moduledoc """
  Global Ask AI modal with deterministic, search-grounded summaries.
  """
  use AgentJidoWeb, :live_component

  alias AgentJido.Search
  alias AgentJido.Search.Result
  alias Phoenix.LiveView.JS

  @default_limit 6

  @type ask_status :: :idle | :loading | :answer | :empty | :error

  @impl true
  @spec update(map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(assigns, socket) do
    socket =
      socket
      |> assign_new(:query, fn -> "" end)
      |> assign_new(:status, fn -> :idle end)
      |> assign_new(:answer, fn -> nil end)
      |> assign_new(:answer_html, fn -> nil end)
      |> assign_new(:citations, fn -> [] end)
      |> assign_new(:ask_ref, fn -> nil end)
      |> assign(Map.drop(assigns, [:ask_complete]))
      |> maybe_apply_ask_complete(assigns)

    {:ok, socket}
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("ask", %{"ask" => %{"q" => raw_query}}, socket) do
    query = normalize_query(raw_query)

    if query == "" do
      {:noreply, assign(socket, query: "", status: :idle, answer: nil, answer_html: nil, citations: [], ask_ref: nil)}
    else
      ask_ref = System.unique_integer([:positive, :monotonic])
      component_id = socket.assigns.id
      live_view_pid = socket.root_pid || self()

      Task.start(fn ->
        response = Search.query_with_status(query, limit: @default_limit)
        send_update(live_view_pid, __MODULE__, id: component_id, ask_complete: {ask_ref, query, response})
      end)

      {:noreply, assign(socket, query: query, status: :loading, answer: nil, answer_html: nil, citations: [], ask_ref: ask_ref)}
    end
  end

  def handle_event("ask_keydown", %{"key" => "Enter"} = params, socket) do
    if truthy?(Map.get(params, "shiftKey")) do
      {:noreply, socket}
    else
      handle_event("ask", %{"ask" => %{"q" => Map.get(params, "value", "")}}, socket)
    end
  end

  def handle_event("ask_keydown", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, query: "", status: :idle, answer: nil, answer_html: nil, citations: [], ask_ref: nil)}
  end

  @impl true
  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id={"#{@id}-root"}>
      <.phx_modal id={@id} on_cancel={JS.push("reset", target: @myself)}>
        <:title>Ask AI</:title>
        <:subtitle>Search-grounded answers from docs, blog, and ecosystem pages.</:subtitle>

        <div class="mt-6 space-y-4">
          <.form for={%{}} as={:ask} phx-submit="ask" phx-target={@myself}>
            <div class="space-y-3">
              <textarea
                id={"#{@id}-input"}
                name="ask[q]"
                rows="3"
                placeholder="Ask a question about Jido..."
                class="w-full resize-y rounded-xl border border-border bg-background px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/25"
                phx-keydown="ask_keydown"
                phx-target={@myself}
              >{@query}</textarea>
              <div class="flex justify-end">
                <button
                  type="submit"
                  class="rounded-xl bg-primary px-5 py-2.5 text-sm font-semibold text-primary-foreground transition hover:bg-primary/90"
                >
                  Ask
                </button>
              </div>
            </div>
          </.form>

          <div :if={@status == :idle} id={"#{@id}-idle"} class="text-sm text-muted-foreground">
            Ask a question to get a deterministic summary with source citations.
          </div>

          <div :if={@status == :loading} id={"#{@id}-loading"} class="text-sm text-foreground">
            Working on "<span class="font-semibold">{@query}</span>"...
          </div>

          <div :if={@status == :answer} id={"#{@id}-answer"} class="space-y-4">
            <div class="rounded-xl border border-border bg-background/70 p-4">
              <div class="prose prose-sm max-w-none text-foreground prose-headings:text-foreground prose-p:text-foreground prose-li:text-foreground prose-a:text-primary">
                {Phoenix.HTML.raw(@answer_html || "")}
              </div>
            </div>

            <div class="space-y-2">
              <p class="text-xs font-semibold uppercase tracking-wide text-primary">Citations</p>
              <%= for citation <- @citations do %>
                <a
                  href={citation.url}
                  phx-click={hide_modal(@id)}
                  class="block rounded-lg border border-border bg-background/70 p-3 transition hover:border-primary/50"
                >
                  <p class="text-sm font-medium text-foreground">{citation.title}</p>
                  <p class="mt-1 text-xs text-muted-foreground">{citation.snippet}</p>
                </a>
              <% end %>
            </div>
          </div>

          <div :if={@status == :empty} id={"#{@id}-empty"} class="text-sm text-muted-foreground">
            I could not find relevant site content for "<span class="font-semibold">{@query}</span>".
          </div>

          <div :if={@status == :error} id={"#{@id}-error"} class="text-sm text-destructive">
            Ask AI is temporarily unavailable right now. Please try again in a moment.
          </div>
        </div>
      </.phx_modal>
    </div>
    """
  end

  @spec maybe_apply_ask_complete(Phoenix.LiveView.Socket.t(), map()) :: Phoenix.LiveView.Socket.t()
  defp maybe_apply_ask_complete(socket, %{ask_complete: {ask_ref, query, response}}) do
    if socket.assigns.ask_ref == ask_ref do
      apply_ask_response(socket, query, response)
    else
      socket
    end
  end

  defp maybe_apply_ask_complete(socket, _assigns), do: socket

  @spec apply_ask_response(Phoenix.LiveView.Socket.t(), String.t(), term()) :: Phoenix.LiveView.Socket.t()
  defp apply_ask_response(socket, query, {:ok, results, _status}) when is_list(results) do
    citations = Enum.take(results, 4)

    if citations == [] do
      assign(socket, query: query, status: :empty, answer: nil, answer_html: nil, citations: [], ask_ref: nil)
    else
      answer = synthesize_answer(query, citations)

      assign(socket,
        query: query,
        status: :answer,
        answer: answer,
        answer_html: markdown_to_html(answer),
        citations: citations,
        ask_ref: nil
      )
    end
  end

  defp apply_ask_response(socket, query, _response) do
    assign(socket, query: query, status: :error, answer: nil, answer_html: nil, citations: [], ask_ref: nil)
  end

  @spec synthesize_answer(String.t(), [Result.t()]) :: String.t()
  defp synthesize_answer(query, citations) do
    bullets =
      citations
      |> Enum.take(3)
      |> Enum.map(fn citation ->
        source_label = source_label(citation.source_type)
        summary = citation.snippet |> String.trim() |> truncate_line(180)
        "- [#{source_label}] [#{citation.title}](#{citation.url}): #{summary}"
      end)
      |> Enum.join("\n")

    [
      "I searched the site content for \"#{query}\" and found these relevant references:",
      "",
      bullets,
      "",
      "Open the citations below for full context."
    ]
    |> Enum.join("\n")
  end

  @spec source_label(atom()) :: String.t()
  defp source_label(:docs), do: "Docs"
  defp source_label(:blog), do: "Blog"
  defp source_label(:ecosystem), do: "Ecosystem"
  defp source_label(_), do: "Content"

  @spec truncate_line(String.t(), pos_integer()) :: String.t()
  defp truncate_line(text, max_len) when is_binary(text) and max_len > 0 do
    if String.length(text) <= max_len do
      text
    else
      String.slice(text, 0, max_len) <> "..."
    end
  end

  @spec markdown_to_html(String.t()) :: String.t()
  defp markdown_to_html(markdown) when is_binary(markdown) do
    case MDEx.to_html(markdown) do
      {:ok, html} ->
        html

      {:error, _reason} ->
        markdown
        |> Phoenix.HTML.html_escape()
        |> Phoenix.HTML.safe_to_string()
    end
  end

  defp markdown_to_html(_markdown), do: ""

  @spec normalize_query(term()) :: String.t()
  defp normalize_query(query) when is_binary(query), do: String.trim(query)
  defp normalize_query(_query), do: ""

  @spec truthy?(term()) :: boolean()
  defp truthy?(value), do: value in [true, "true", 1, "1", "on"]
end
