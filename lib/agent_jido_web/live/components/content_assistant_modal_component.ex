defmodule AgentJidoWeb.ContentAssistantModalComponent do
  @moduledoc """
  Unified content assistant modal for retrieval-grounded search and chat.
  """
  use AgentJidoWeb, :live_component

  alias AgentJido.Analytics
  alias AgentJido.ContentAssistant
  alias AgentJido.ContentAssistant.Response
  alias AgentJido.QueryLogs
  alias Phoenix.LiveView.JS

  @default_citation_limit 6
  @default_thread_limit 8
  @default_progressive_swap_min_ms 1_200

  @type assistant_status :: :idle | :loading | :answer | :empty | :error

  @impl true
  @spec update(map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(assigns, socket) do
    component_id = component_id(socket, assigns)

    socket =
      socket
      |> assign_new(:query, fn -> "" end)
      |> assign_new(:status, fn -> :idle end)
      |> assign_new(:response, fn -> nil end)
      |> assign_new(:assistant_ref, fn -> nil end)
      |> assign_new(:assistant_started_at, fn -> nil end)
      |> assign_new(:enhancement_ref, fn -> nil end)
      |> assign_new(:enhancement_status, fn -> :idle end)
      |> assign_new(:query_log_id, fn -> nil end)
      |> assign_new(:last_query_log_id, fn -> nil end)
      |> assign_new(:thread, fn -> [] end)
      |> assign_new(:feedback_value, fn -> nil end)
      |> assign_new(:feedback_note, fn -> "" end)
      |> assign_new(:feedback_submitted, fn -> false end)
      |> assign_new(:turnstile_token, fn -> "" end)
      |> assign_new(:current_scope, fn -> nil end)
      |> assign_new(:analytics_identity, fn -> %{visitor_id: nil, session_id: nil, referrer_host: nil, path: nil} end)
      |> assign(Map.drop(assigns, [:assistant_complete, :assistant_enhancement_complete]))
      |> assign(:turnstile_required, require_turnstile?())
      |> assign(:turnstile_site_key, turnstile_site_key())
      |> assign(:turnstile_widget_id, turnstile_widget_id(component_id))
      |> assign(:turnstile_input_id, turnstile_input_id(component_id))
      |> maybe_apply_assistant_complete(assigns)
      |> maybe_apply_assistant_enhancement_complete(assigns)

    {:ok, socket}
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("submit", %{"assistant" => params}, socket) do
    query = normalize_query(Map.get(params, "q"))
    turnstile_token = normalize_query(Map.get(params, "turnstile_token"))

    if query == "" do
      {:noreply,
       socket
       |> assign(
         query: "",
         status: :idle,
         response: nil,
         assistant_ref: nil,
         assistant_started_at: nil,
         enhancement_ref: nil,
         enhancement_status: :idle,
         query_log_id: nil,
         last_query_log_id: nil,
         feedback_value: nil,
         feedback_note: "",
         feedback_submitted: false,
         turnstile_token: ""
       )
       |> reset_turnstile_widget()}
    else
      assistant_ref = System.unique_integer([:positive, :monotonic])
      component_id = socket.assigns.id
      live_view_pid = socket.root_pid || self()
      query_log_id = track_query_id(query, socket)
      assistant_module = content_assistant_module()
      assistant_opts = assistant_opts(socket, turnstile_token, :fast)

      Task.start(fn ->
        response = run_content_assistant(assistant_module, query, query_log_id, assistant_opts)
        send_update(live_view_pid, __MODULE__, id: component_id, assistant_complete: {assistant_ref, query, response})
      end)

      {:noreply,
       assign(socket,
         query: query,
         status: :loading,
         response: nil,
         assistant_ref: assistant_ref,
         assistant_started_at: System.monotonic_time(),
         enhancement_ref: nil,
         enhancement_status: :idle,
         query_log_id: query_log_id,
         last_query_log_id: nil,
         feedback_value: nil,
         feedback_note: "",
         feedback_submitted: false,
         turnstile_token: turnstile_token
       )}
    end
  end

  def handle_event("reference_click", params, socket) do
    rank = normalize_rank(Map.get(params, "rank"))
    target_url = normalize_query(Map.get(params, "url"))
    response = socket.assigns.response

    analytics_module().track_event_safe(socket.assigns.current_scope, %{
      event: "content_assistant_reference_clicked",
      source: "content_assistant",
      channel: "content_assistant_modal",
      path: socket.assigns.analytics_identity[:path] || "/",
      target_url: target_url,
      rank: rank,
      query_log_id: socket.assigns.last_query_log_id,
      visitor_id: socket.assigns.analytics_identity[:visitor_id],
      session_id: socket.assigns.analytics_identity[:session_id],
      metadata: analytics_metadata(response, %{surface: "content_assistant_modal"})
    })

    {:noreply, socket}
  end

  def handle_event("submit_feedback", %{"feedback" => feedback_params}, socket) do
    feedback_value = normalize_feedback_value(Map.get(feedback_params, "value"))

    feedback_note =
      if feedback_value == "not_helpful" do
        normalize_feedback_note(Map.get(feedback_params, "note"))
      else
        nil
      end

    if feedback_value in ["helpful", "not_helpful"] do
      response = socket.assigns.response
      channel = if socket.assigns.status == :empty, do: "content_assistant_no_results", else: "content_assistant_modal"

      analytics_module().track_feedback_safe(socket.assigns.current_scope, %{
        event: "feedback_submitted",
        source: "content_assistant",
        channel: channel,
        path: socket.assigns.analytics_identity[:path] || "/",
        feedback_value: feedback_value,
        feedback_note: feedback_note,
        query_log_id: socket.assigns.last_query_log_id,
        visitor_id: socket.assigns.analytics_identity[:visitor_id],
        session_id: socket.assigns.analytics_identity[:session_id],
        metadata: analytics_metadata(response, %{surface: "content_assistant"})
      })

      {:noreply,
       assign(socket,
         feedback_value: feedback_value,
         feedback_note: "",
         feedback_submitted: true
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("feedback_select", %{"value" => value}, socket) do
    case normalize_feedback_value(value) do
      "helpful" ->
        {:noreply, assign(socket, feedback_value: "helpful", feedback_note: "", feedback_submitted: false)}

      "not_helpful" ->
        {:noreply, assign(socket, feedback_value: "not_helpful", feedback_submitted: false)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("new_topic", _params, socket) do
    {:noreply,
     socket
     |> assign(
       query: "",
       status: :idle,
       response: nil,
       assistant_ref: nil,
       assistant_started_at: nil,
       enhancement_ref: nil,
       enhancement_status: :idle,
       query_log_id: nil,
       last_query_log_id: nil,
       thread: [],
       feedback_value: nil,
       feedback_note: "",
       feedback_submitted: false,
       turnstile_token: ""
     )
     |> reset_turnstile_widget()}
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(
       query: "",
       status: :idle,
       response: nil,
       assistant_ref: nil,
       assistant_started_at: nil,
       enhancement_ref: nil,
       enhancement_status: :idle,
       query_log_id: nil,
       last_query_log_id: nil,
       feedback_value: nil,
       feedback_note: "",
       feedback_submitted: false,
       turnstile_token: ""
     )
     |> reset_turnstile_widget()}
  end

  @impl true
  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id={"#{@id}-root"}>
      <.phx_modal id={@id} on_cancel={JS.push("reset", target: @myself)}>
        <:title>Search</:title>
        <:subtitle>Search docs, blog posts, and ecosystem packages, then chat with the results.</:subtitle>

        <div class="mt-6 space-y-4">
          <.form for={%{}} as={:assistant} phx-submit="submit" phx-target={@myself}>
            <div class="space-y-3">
              <input
                id={@turnstile_input_id}
                name="assistant[turnstile_token]"
                type="text"
                value={@turnstile_token}
                class="hidden"
                autocomplete="off"
                aria-hidden="true"
              />

              <div class="flex flex-col gap-3 sm:flex-row">
                <input
                  id={"#{@id}-input"}
                  name="assistant[q]"
                  type="search"
                  value={@query}
                  placeholder="Ask about Jido docs, blog, and ecosystem..."
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

              <div :if={@turnstile_required and is_binary(@turnstile_site_key) and @turnstile_site_key != ""}>
                <div
                  id={@turnstile_widget_id}
                  phx-hook="ContentAssistantTurnstile"
                  data-site-key={@turnstile_site_key}
                  data-input-id={@turnstile_input_id}
                  data-appearance="interaction-only"
                  data-size="invisible"
                  data-execution="execute"
                  class="h-0 overflow-hidden"
                >
                </div>
                <p class="mt-1 text-xs text-muted-foreground">
                  Verification runs in the background and only prompts when risk is detected.
                </p>
              </div>
            </div>
          </.form>

          <div :if={@status == :idle} id={"#{@id}-idle"} class="text-sm text-muted-foreground">
            Enter a question to get a grounded answer with citations.
          </div>

          <div
            :if={@status == :loading}
            id={"#{@id}-loading"}
            class="rounded-xl border border-border bg-background/70 p-4"
          >
            <div class="assistant-loading-indicator text-sm text-foreground">
              <span class="assistant-loading-dots" aria-hidden="true">
                <span></span>
                <span></span>
                <span></span>
              </span>
              <span>Working on "<span class="font-semibold">{@query}</span>"...</span>
            </div>
            <div class="mt-3 space-y-2">
              <div class="h-2 w-full rounded bg-primary/20 animate-pulse"></div>
              <div class="h-2 w-5/6 rounded bg-primary/15 animate-pulse"></div>
              <div class="h-2 w-2/3 rounded bg-primary/10 animate-pulse"></div>
            </div>
          </div>

          <div :if={@status == :answer and is_map(@response)} id={"#{@id}-answer"} class="space-y-4">
            <div
              :if={fallback_banner(@response)}
              class="rounded-lg border border-accent-yellow/30 bg-accent-yellow/10 p-3 text-xs font-semibold text-accent-yellow"
            >
              {fallback_banner(@response)}
            </div>

            <div class="rounded-xl border border-border bg-background/70 p-4">
              <div class="prose prose-sm content-assistant-prose max-w-none text-foreground prose-headings:text-foreground prose-p:text-foreground prose-li:text-foreground prose-a:text-primary">
                {Phoenix.HTML.raw(@response.answer_html || "")}
              </div>
            </div>

            <div
              :if={@enhancement_status == :running}
              id={"#{@id}-enhancing"}
              class="rounded-lg border border-primary/30 bg-primary/5 p-3 text-xs text-foreground"
            >
              <div class="assistant-loading-indicator">
                <span class="assistant-loading-dots" aria-hidden="true">
                  <span></span>
                  <span></span>
                  <span></span>
                </span>
                <span>Improving this answer with the LLM...</span>
              </div>
            </div>

            <div class="space-y-2">
              <p class="text-xs font-semibold uppercase tracking-wide text-primary">Citations</p>
              <div class="search-modal-scrollbar max-h-[34vh] overflow-y-auto pr-1 space-y-2">
                <%= for {citation, rank} <- Enum.with_index(@response.citations || [], 1) do %>
                  <a
                    href={citation.url}
                    phx-click={JS.push("reference_click", target: @myself, value: %{url: citation.url, rank: rank}) |> hide_modal(@id)}
                    class="block rounded-lg border border-border bg-background/70 p-3 transition hover:border-primary/50"
                  >
                    <div class="mb-1 flex items-center justify-between gap-2">
                      <p class="text-xs font-semibold uppercase tracking-wide text-primary">
                        {source_label(citation.source_type)}
                      </p>
                      <span class="text-[11px] text-muted-foreground">Open</span>
                    </div>
                    <p class="text-sm font-medium text-foreground">{citation.title}</p>
                    <p class="mt-1 text-xs text-muted-foreground">{citation.snippet}</p>
                  </a>
                <% end %>
              </div>
            </div>

            <.feedback_prompt
              id={"#{@id}-feedback"}
              form_id={"#{@id}-feedback-form"}
              title="Was this answer helpful?"
              value={@feedback_value}
              note={@feedback_note}
              submitted={@feedback_submitted}
              select_event="feedback_select"
              submit_event="submit_feedback"
              target={@myself}
              note_placeholder="What would make this answer better?"
            />
          </div>

          <div :if={@status == :empty} id={"#{@id}-empty"} class="space-y-3 text-sm text-muted-foreground">
            <p>No relevant content found for "<span class="font-semibold">{@query}</span>".</p>

            <.feedback_prompt
              id={"#{@id}-no-results-feedback"}
              form_id={"#{@id}-no-results-feedback-form"}
              title="Was this result helpful?"
              value={@feedback_value}
              note={@feedback_note}
              submitted={@feedback_submitted}
              select_event="feedback_select"
              submit_event="submit_feedback"
              target={@myself}
              note_placeholder="What were you trying to find?"
            />
          </div>

          <div :if={@status == :error} id={"#{@id}-error"} class="text-sm text-destructive">
            Content assistant is temporarily unavailable right now. Please try again in a moment.
          </div>

          <div :if={@thread != []} class="space-y-2 border-t border-border pt-4">
            <p class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Recent thread</p>
            <div class="search-modal-scrollbar max-h-[22vh] overflow-y-auto space-y-2 pr-1">
              <%= for turn <- @thread do %>
                <div class="rounded-md border border-border bg-background/70 p-2">
                  <p class="text-xs font-semibold text-foreground">{turn.query}</p>
                  <p class="mt-1 text-[11px] text-muted-foreground">
                    {turn.mode_label} • {turn.citations_count} reference{if turn.citations_count == 1, do: "", else: "s"}
                  </p>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </.phx_modal>
    </div>
    """
  end

  @spec maybe_apply_assistant_complete(Phoenix.LiveView.Socket.t(), map()) :: Phoenix.LiveView.Socket.t()
  defp maybe_apply_assistant_complete(socket, %{assistant_complete: {assistant_ref, query, response}}) do
    if socket.assigns.assistant_ref == assistant_ref do
      response = maybe_prepare_progressive_fast_response(socket, response)
      apply_assistant_response(socket, query, response)
    else
      socket
    end
  end

  defp maybe_apply_assistant_complete(socket, _assigns), do: socket

  @spec maybe_apply_assistant_enhancement_complete(Phoenix.LiveView.Socket.t(), map()) :: Phoenix.LiveView.Socket.t()
  defp maybe_apply_assistant_enhancement_complete(socket, %{assistant_enhancement_complete: {enhancement_ref, _query, response}}) do
    if socket.assigns.enhancement_ref == enhancement_ref do
      apply_enhancement_response(socket, response)
    else
      socket
    end
  end

  defp maybe_apply_assistant_enhancement_complete(socket, _assigns), do: socket

  @spec apply_assistant_response(Phoenix.LiveView.Socket.t(), String.t(), Response.t()) :: Phoenix.LiveView.Socket.t()
  defp apply_assistant_response(socket, query, %Response{} = response) do
    latency_ms = query_latency_ms(socket.assigns.assistant_started_at)

    {status, query_status, results_count} =
      case response.answer_mode do
        :error -> {:error, "error", 0}
        :no_results -> {:empty, "no_results", 0}
        _mode -> {:answer, "success", length(response.citations || [])}
      end

    finalize_query_log(socket.assigns.query_log_id, query_status, results_count, latency_ms)

    assign(socket,
      query: query,
      status: status,
      response: response,
      assistant_ref: nil,
      assistant_started_at: nil,
      enhancement_ref: nil,
      enhancement_status: :idle,
      query_log_id: nil,
      last_query_log_id: socket.assigns.query_log_id,
      thread: append_thread(socket.assigns.thread, response),
      turnstile_token: ""
    )
    |> reset_turnstile_widget()
    |> maybe_start_progressive_enhancement(query, response)
  end

  defp apply_assistant_response(socket, query, _response) do
    latency_ms = query_latency_ms(socket.assigns.assistant_started_at)
    finalize_query_log(socket.assigns.query_log_id, "error", 0, latency_ms)

    assign(socket,
      query: query,
      status: :error,
      response: nil,
      assistant_ref: nil,
      assistant_started_at: nil,
      enhancement_ref: nil,
      enhancement_status: :idle,
      query_log_id: nil,
      last_query_log_id: socket.assigns.query_log_id,
      turnstile_token: ""
    )
    |> reset_turnstile_widget()
  end

  defp run_content_assistant(module, query, query_log_id, opts) when is_atom(module) do
    case module.respond(query, Keyword.put(opts, :query_log_id, query_log_id)) do
      {:ok, %Response{} = response} ->
        response

      {:ok, _other} ->
        error_response(query, query_log_id)

      _other ->
        error_response(query, query_log_id)
    end
  rescue
    _ -> error_response(query, query_log_id)
  end

  defp run_content_assistant(_module, query, query_log_id, _opts), do: error_response(query, query_log_id)

  defp error_response(query, query_log_id) do
    %Response{
      query: query,
      answer_markdown: "",
      answer_html: "",
      answer_mode: :error,
      citations: [],
      retrieval_status: :failure,
      llm_attempted?: false,
      llm_enhanced?: false,
      enhancement_blocked_reason: nil,
      query_log_id: query_log_id
    }
  end

  defp maybe_prepare_progressive_fast_response(socket, %Response{} = response) do
    enhancement_opts = assistant_opts(socket, "", :enhancement)

    if should_start_progressive_enhancement?(response, enhancement_opts) do
      %Response{
        response
        | enhancement_blocked_reason: nil
      }
    else
      response
    end
  end

  defp maybe_prepare_progressive_fast_response(_socket, response), do: response

  defp maybe_start_progressive_enhancement(socket, query, %Response{} = response) do
    enhancement_opts = assistant_opts(socket, "", :enhancement)

    if should_start_progressive_enhancement?(response, enhancement_opts) do
      enhancement_ref = System.unique_integer([:positive, :monotonic])
      component_id = socket.assigns.id
      live_view_pid = socket.root_pid || self()
      assistant_module = content_assistant_module()

      Task.start(fn ->
        enhancement_started_at_ms = monotonic_ms()
        enhancement_response = run_content_assistant(assistant_module, query, nil, enhancement_opts)
        maybe_wait_for_progressive_dwell(enhancement_started_at_ms)

        send_update(
          live_view_pid,
          __MODULE__,
          id: component_id,
          assistant_enhancement_complete: {enhancement_ref, query, enhancement_response}
        )
      end)

      assign(socket, enhancement_ref: enhancement_ref, enhancement_status: :running)
    else
      assign(socket, enhancement_ref: nil, enhancement_status: :idle)
    end
  end

  defp maybe_start_progressive_enhancement(socket, _query, _response), do: assign(socket, enhancement_ref: nil, enhancement_status: :idle)

  defp apply_enhancement_response(socket, %Response{answer_mode: :llm} = response) do
    assign(socket,
      response: response,
      thread: replace_latest_thread_entry(socket.assigns.thread, response),
      enhancement_ref: nil,
      enhancement_status: :complete
    )
  end

  defp apply_enhancement_response(socket, _response) do
    assign(socket, enhancement_ref: nil, enhancement_status: :failed)
  end

  defp should_start_progressive_enhancement?(%Response{} = response, enhancement_opts) when is_list(enhancement_opts) do
    progressive_mode?() and
      response.answer_mode != :llm and
      length(response.citations || []) > 0 and
      llm_enabled?(enhancement_opts)
  end

  defp should_start_progressive_enhancement?(_response, _enhancement_opts), do: false

  defp llm_enabled?(opts) when is_list(opts) do
    case Keyword.fetch(opts, :llm) do
      {:ok, llm} -> not is_nil(llm)
      :error -> not is_nil(Application.get_env(:arcana, :llm))
    end
  end

  defp llm_enabled?(_opts), do: false

  defp assistant_opts(socket, turnstile_token, stage) do
    retrieval_opts = [mode: search_retrieval_mode(), graph: false]

    default_opts =
      [
        citation_limit: @default_citation_limit,
        turnstile_token: turnstile_token,
        surface: "content_assistant_modal",
        metadata: %{surface: "content_assistant_modal"},
        retrieval_opts: retrieval_opts
      ]
      |> maybe_apply_search_response_mode(stage)

    session_opts =
      case socket.assigns[:assistant_opts] do
        opts when is_list(opts) -> opts
        _ -> []
      end

    Keyword.merge(default_opts, session_opts)
  end

  defp append_thread(thread, %Response{} = response) do
    item = %{
      query: response.query,
      mode_label: mode_label(response.answer_mode),
      citations_count: length(response.citations || [])
    }

    [item | List.wrap(thread)]
    |> Enum.take(@default_thread_limit)
  end

  defp append_thread(thread, _response), do: List.wrap(thread)

  defp replace_latest_thread_entry([_latest | rest], %Response{} = response) do
    [
      %{
        query: response.query,
        mode_label: mode_label(response.answer_mode),
        citations_count: length(response.citations || [])
      }
      | rest
    ]
  end

  defp replace_latest_thread_entry(thread, _response), do: thread

  defp fallback_banner(%Response{answer_mode: :quota_fallback}) do
    "LLM quota or rate limits are active. Showing citation-grounded fallback."
  end

  defp fallback_banner(%Response{answer_mode: :deterministic_fallback}) do
    "LLM response is temporarily unavailable. Showing citation-grounded fallback."
  end

  defp fallback_banner(%Response{enhancement_blocked_reason: :turnstile}) do
    "Verification challenge was incomplete. Showing deterministic citation-grounded response."
  end

  defp fallback_banner(%Response{enhancement_blocked_reason: :budget}) do
    "LLM enhancement is currently budget-limited. Showing deterministic citation-grounded response."
  end

  defp fallback_banner(%Response{enhancement_blocked_reason: :llm_unconfigured}) do
    "LLM enhancement is not configured. Showing deterministic citation-grounded response."
  end

  defp fallback_banner(_response), do: nil

  defp source_label(:docs), do: "Docs"
  defp source_label(:blog), do: "Blog"
  defp source_label(:ecosystem), do: "Ecosystem"
  defp source_label(_), do: "Content"

  defp mode_label(:llm), do: "LLM"
  defp mode_label(:deterministic), do: "Deterministic"
  defp mode_label(:deterministic_fallback), do: "Deterministic fallback"
  defp mode_label(:quota_fallback), do: "Quota fallback"
  defp mode_label(:no_results), do: "No results"
  defp mode_label(:error), do: "Error"

  defp mode_label(mode) when is_atom(mode), do: mode |> Atom.to_string() |> String.replace("_", " ")
  defp mode_label(_mode), do: "Unknown"

  defp normalize_query(query) when is_binary(query), do: String.trim(query)
  defp normalize_query(_query), do: ""

  defp normalize_feedback_value(value) when is_binary(value) do
    case String.trim(value) do
      "helpful" -> "helpful"
      "not_helpful" -> "not_helpful"
      _ -> nil
    end
  end

  defp normalize_feedback_value(_value), do: nil

  defp normalize_feedback_note(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.slice(0, 500)
    |> case do
      "" -> nil
      note -> note
    end
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

  defp track_query_id(query, socket) when is_binary(query) do
    query_log_id =
      case QueryLogs.track_query_safe(socket.assigns.current_scope, socket.assigns.analytics_identity, %{
             source: "content_assistant",
             channel: "content_assistant_modal",
             query: query,
             status: "submitted",
             path: socket.assigns.analytics_identity[:path],
             referrer_host: socket.assigns.analytics_identity[:referrer_host],
             metadata: %{surface: "content_assistant_modal"}
           }) do
        %{id: id} -> id
        _ -> nil
      end

    analytics_module().track_event_safe(socket.assigns.current_scope, %{
      event: "content_assistant_submitted",
      source: "content_assistant",
      channel: "content_assistant_modal",
      path: socket.assigns.analytics_identity[:path] || "/",
      query_log_id: query_log_id,
      visitor_id: socket.assigns.analytics_identity[:visitor_id],
      session_id: socket.assigns.analytics_identity[:session_id],
      metadata: %{surface: "content_assistant_modal", query: query}
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

  defp progressive_swap_min_ms do
    case content_assistant_config() |> config_value(:progressive_swap_min_ms, @default_progressive_swap_min_ms) do
      value when is_integer(value) and value >= 0 -> value
      _ -> @default_progressive_swap_min_ms
    end
  end

  defp maybe_wait_for_progressive_dwell(started_at_ms) when is_integer(started_at_ms) do
    remaining_ms = progressive_swap_min_ms() - (monotonic_ms() - started_at_ms)

    if remaining_ms > 0 do
      Process.sleep(remaining_ms)
    end
  end

  defp maybe_wait_for_progressive_dwell(_started_at_ms), do: :ok

  defp monotonic_ms do
    System.monotonic_time()
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp reset_turnstile_widget(socket) do
    if socket.assigns[:turnstile_required] do
      push_event(socket, "content_assistant_turnstile_reset", %{id: socket.assigns.turnstile_widget_id})
    else
      socket
    end
  end

  defp turnstile_widget_id(id), do: "#{id}-turnstile"
  defp turnstile_input_id(id), do: "#{id}-turnstile-token"

  defp component_id(socket, assigns) do
    Map.get(assigns, :id) || Map.get(socket.assigns, :id) || "primary-nav-content-assistant-modal"
  end

  defp require_turnstile? do
    turnstile_required =
      content_assistant_config()
      |> config_value(:require_turnstile, false)
      |> truthy?()

    search_response_mode() == :enhanced and turnstile_required
  end

  defp turnstile_site_key do
    content_assistant_config()
    |> config_value(:turnstile_site_key, nil)
  end

  defp analytics_metadata(%Response{} = response, metadata) when is_map(metadata) do
    Map.merge(metadata, %{
      answer_mode: response.answer_mode,
      retrieval_status: response.retrieval_status,
      llm_attempted: response.llm_attempted?,
      llm_enhanced: response.llm_enhanced?,
      enhancement_blocked_reason: response.enhancement_blocked_reason
    })
  end

  defp analytics_metadata(_response, metadata) when is_map(metadata), do: metadata

  defp content_assistant_module do
    Application.get_env(:agent_jido, :content_assistant_module, ContentAssistant)
  end

  defp content_assistant_config do
    Application.get_env(:agent_jido, AgentJido.ContentAssistant, [])
  end

  defp config_value(config, key, default) when is_list(config), do: Keyword.get(config, key, default)
  defp config_value(config, key, default) when is_map(config), do: Map.get(config, key, default)
  defp config_value(_config, _key, default), do: default

  defp truthy?(value), do: value in [true, "true", 1, "1", "on"]

  defp maybe_apply_search_response_mode(opts, stage) when is_list(opts) do
    case {search_response_mode(), stage} do
      {:enhanced, _stage} ->
        opts

      {:deterministic, _stage} ->
        opts
        |> Keyword.put(:llm, nil)
        |> Keyword.put(:require_turnstile, false)

      {:progressive, :enhancement} ->
        opts
        |> Keyword.put_new(:llm, Application.get_env(:arcana, :llm))
        |> Keyword.put(:require_turnstile, false)

      {:progressive, _stage} ->
        opts
        |> Keyword.put(:llm, nil)
        |> Keyword.put(:require_turnstile, false)
    end
  end

  defp maybe_apply_search_response_mode(opts, _stage), do: opts

  defp search_response_mode do
    case content_assistant_config() |> config_value(:search_response_mode, :progressive) do
      mode when mode in [:progressive, "progressive"] -> :progressive
      mode when mode in [:enhanced, "enhanced"] -> :enhanced
      _ -> :deterministic
    end
  end

  defp progressive_mode?, do: search_response_mode() == :progressive

  defp search_retrieval_mode do
    case content_assistant_config() |> config_value(:search_retrieval_mode, :fulltext) do
      mode when mode in [:hybrid, "hybrid"] -> :hybrid
      _ -> :fulltext
    end
  end

  defp analytics_module do
    Application.get_env(:agent_jido, :analytics_module, Analytics)
  end
end
