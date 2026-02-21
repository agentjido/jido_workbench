defmodule AgentJidoWeb.NavAskAiModalComponent do
  @moduledoc """
  Global Ask AI modal with search-grounded summaries and LLM enhancement.
  """
  use AgentJidoWeb, :live_component

  alias AgentJido.AskAi
  alias AgentJido.AskAi.Turnstile
  alias AgentJido.Search
  alias Phoenix.LiveView.JS

  @default_limit 6

  @type ask_status :: :idle | :loading | :answer | :empty | :error | :challenge

  @impl true
  @spec update(map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(assigns, socket) do
    socket =
      socket
      |> assign_new(:query, fn -> "" end)
      |> assign_new(:status, fn -> :idle end)
      |> assign_new(:answer, fn -> nil end)
      |> assign_new(:answer_html, fn -> nil end)
      |> assign_new(:answer_mode, fn -> nil end)
      |> assign_new(:citations, fn -> [] end)
      |> assign_new(:ask_ref, fn -> nil end)
      |> assign_new(:turnstile_error, fn -> nil end)
      |> assign_new(:turnstile_token, fn -> "" end)
      |> assign(Map.drop(assigns, [:ask_complete]))
      |> assign(:turnstile_required, require_turnstile?())
      |> assign(:turnstile_site_key, turnstile_site_key())
      |> assign(:turnstile_widget_id, turnstile_widget_id(component_id(socket, assigns)))
      |> assign(:turnstile_input_id, turnstile_input_id(component_id(socket, assigns)))
      |> maybe_apply_ask_complete(assigns)

    {:ok, socket}
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("ask", %{"ask" => ask_params}, socket) do
    raw_query = Map.get(ask_params, "q")
    turnstile_token = Map.get(ask_params, "turnstile_token")
    query = normalize_query(raw_query)

    if query == "" do
      {:noreply,
       assign(socket,
         query: "",
         status: :idle,
         answer: nil,
         answer_html: nil,
         answer_mode: nil,
         citations: [],
         ask_ref: nil,
         turnstile_error: nil,
         turnstile_token: ""
       )}
    else
      case verify_turnstile(socket, turnstile_token) do
        {:ok, socket} ->
          ask_ref = System.unique_integer([:positive, :monotonic])
          component_id = socket.assigns.id
          live_view_pid = socket.root_pid || self()
          search_module = search_module()

          Task.start(fn ->
            response = run_search(search_module, query)
            send_update(live_view_pid, __MODULE__, id: component_id, ask_complete: {ask_ref, query, response})
          end)

          {:noreply,
           assign(socket,
             query: query,
             status: :loading,
             answer: nil,
             answer_html: nil,
             answer_mode: nil,
             citations: [],
             ask_ref: ask_ref
           )}

        {:error, socket} ->
          {:noreply, socket}
      end
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
    socket =
      socket
      |> assign(
        query: "",
        status: :idle,
        answer: nil,
        answer_html: nil,
        answer_mode: nil,
        citations: [],
        ask_ref: nil,
        turnstile_error: nil,
        turnstile_token: ""
      )
      |> reset_turnstile_widget()

    {:noreply, socket}
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
              <input
                id={@turnstile_input_id}
                name="ask[turnstile_token]"
                type="text"
                value={@turnstile_token}
                class="hidden"
                autocomplete="off"
                aria-hidden="true"
              />

              <textarea
                id={"#{@id}-input"}
                name="ask[q]"
                rows="3"
                placeholder="Ask a question about Jido..."
                class="w-full resize-y rounded-xl border border-border bg-background px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/25"
                phx-keydown="ask_keydown"
                phx-target={@myself}
              >{@query}</textarea>

              <div :if={@turnstile_required} class="space-y-2">
                <div
                  id={@turnstile_widget_id}
                  phx-hook="AskAiTurnstile"
                  data-site-key={@turnstile_site_key}
                  data-input-id={@turnstile_input_id}
                  class="min-h-16"
                >
                </div>
                <p
                  :if={is_binary(@turnstile_error) and @turnstile_error != ""}
                  class="text-xs font-semibold text-amber-300"
                >
                  {@turnstile_error}
                </p>
              </div>

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
            <div
              :if={fallback_banner(@answer_mode)}
              id={"#{@id}-fallback-banner"}
              class="rounded-lg border border-amber-400/30 bg-amber-100/10 p-3 text-xs font-semibold text-amber-200"
            >
              {fallback_banner(@answer_mode)}
            </div>

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

          <div :if={@status == :challenge} id={"#{@id}-challenge"} class="text-sm text-amber-300">
            Complete the verification challenge and submit again.
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
      assign(socket,
        query: query,
        status: :empty,
        answer: nil,
        answer_html: nil,
        answer_mode: nil,
        citations: [],
        ask_ref: nil
      )
    else
      {answer, status, mode} =
        case ask_ai_module().summarize(query, citations) do
          {:ok, response, mode} when is_binary(response) and response != "" -> {response, :answer, mode}
          _other -> {nil, :error, nil}
        end

      assign(socket,
        query: query,
        status: status,
        answer: answer,
        answer_html: markdown_to_html(answer || ""),
        answer_mode: mode,
        citations: citations,
        ask_ref: nil,
        turnstile_error: nil
      )
    end
  end

  defp apply_ask_response(socket, query, _response) do
    assign(socket,
      query: query,
      status: :error,
      answer: nil,
      answer_html: nil,
      answer_mode: nil,
      citations: [],
      ask_ref: nil
    )
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

  defp verify_turnstile(socket, token) do
    if socket.assigns.turnstile_required do
      case turnstile_verifier_module().verify(token, nil) do
        :ok ->
          {:ok,
           socket
           |> assign(turnstile_error: nil, turnstile_token: "")
           |> reset_turnstile_widget()}

        {:error, reason} ->
          {:error,
           socket
           |> assign(
             status: :challenge,
             answer: nil,
             answer_html: nil,
             answer_mode: nil,
             citations: [],
             ask_ref: nil,
             turnstile_error: turnstile_error_message(reason),
             turnstile_token: ""
           )
           |> reset_turnstile_widget()}
      end
    else
      {:ok, assign(socket, turnstile_token: token || "", turnstile_error: nil)}
    end
  end

  defp reset_turnstile_widget(socket) do
    if socket.assigns[:turnstile_required] do
      push_event(socket, "ask_ai_turnstile_reset", %{id: socket.assigns.turnstile_widget_id})
    else
      socket
    end
  end

  defp fallback_banner(:quota_fallback) do
    "LLM quota or rate limits are active. Showing citation-grounded fallback."
  end

  defp fallback_banner(:deterministic_fallback) do
    "LLM response is temporarily unavailable. Showing citation-grounded fallback."
  end

  defp fallback_banner(_mode), do: nil

  defp turnstile_error_message(:missing_token), do: "Please complete the Turnstile challenge."
  defp turnstile_error_message(:not_configured), do: "Turnstile is not configured for Ask AI."
  defp turnstile_error_message({:invalid_token, _codes}), do: "Challenge verification failed. Please try again."
  defp turnstile_error_message({:request_failed, _reason}), do: "Could not verify challenge. Please try again."
  defp turnstile_error_message(_reason), do: "Challenge verification failed."

  defp turnstile_widget_id(id), do: "#{id}-turnstile"
  defp turnstile_input_id(id), do: "#{id}-turnstile-token"

  defp component_id(socket, assigns) do
    Map.get(assigns, :id) || Map.get(socket.assigns, :id) || "primary-nav-ask-ai-modal"
  end

  defp require_turnstile? do
    ask_ai_config()
    |> config_value(:require_turnstile, false)
    |> truthy?()
  end

  defp turnstile_site_key do
    ask_ai_config()
    |> config_value(:turnstile_site_key, nil)
  end

  defp ask_ai_module do
    Application.get_env(:agent_jido, :ask_ai_module, AskAi)
  end

  defp search_module do
    Application.get_env(:agent_jido, :ask_ai_search_module, Search)
  end

  defp turnstile_verifier_module do
    Application.get_env(:agent_jido, :ask_ai_turnstile_module, Turnstile)
  end

  defp ask_ai_config do
    Application.get_env(:agent_jido, AskAi, [])
  end

  defp config_value(config, key, default) when is_list(config), do: Keyword.get(config, key, default)
  defp config_value(config, key, default) when is_map(config), do: Map.get(config, key, default)
  defp config_value(_config, _key, default), do: default

  @spec truthy?(term()) :: boolean()
  defp truthy?(value), do: value in [true, "true", 1, "1", "on"]
end
