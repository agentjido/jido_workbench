defmodule AgentJidoWeb.ContentAssistantModalComponentTest do
  use AgentJidoWeb.ConnCase, async: false

  import Ecto.Query
  import Phoenix.LiveViewTest

  alias AgentJido.Analytics.AnalyticsEvent
  alias AgentJido.ContentAssistant.Response
  alias AgentJido.ContentAssistant.Result
  alias AgentJido.QueryLogs.QueryLog

  defmodule ContentAssistantStub do
    def respond("agents", _opts) do
      {:ok,
       %Response{
         query: "agents",
         answer_markdown: "Agent overview",
         answer_html: "<p>Agent overview</p>",
         answer_mode: :llm,
         citations: [
           %Result{
             title: "Agents",
             snippet: "Agents model state and command boundaries.",
             url: "/docs/concepts/agents",
             source_type: :docs,
             score: 0.95
           }
         ],
         retrieval_status: :success,
         llm_attempted?: true,
         llm_enhanced?: true,
         enhancement_blocked_reason: nil,
         query_log_id: nil
       }}
    end

    def respond("none", _opts) do
      {:ok,
       %Response{
         query: "none",
         answer_markdown: "",
         answer_html: "",
         answer_mode: :no_results,
         citations: [],
         retrieval_status: :success,
         llm_attempted?: false,
         llm_enhanced?: false,
         enhancement_blocked_reason: :llm_unconfigured,
         query_log_id: nil
       }}
    end

    def respond(_query, _opts) do
      {:ok,
       %Response{
         query: "",
         answer_markdown: "",
         answer_html: "",
         answer_mode: :error,
         citations: [],
         retrieval_status: :failure,
         llm_attempted?: false,
         llm_enhanced?: false,
         enhancement_blocked_reason: nil,
         query_log_id: nil
       }}
    end
  end

  defmodule AssistantOptsCaptureStub do
    @moduledoc false

    @spec respond(String.t(), keyword()) :: {:ok, Response.t()}
    def respond(query, opts \\ []) do
      if pid = :persistent_term.get({__MODULE__, :test_pid}, nil) do
        send(pid, {:modal_opts_capture, query, opts})
      end

      {:ok,
       %Response{
         query: query,
         answer_markdown: "Captured options for #{query}",
         answer_html: "<p>Captured options for #{query}</p>",
         answer_mode: :deterministic,
         citations: [],
         retrieval_status: :success,
         llm_attempted?: false,
         llm_enhanced?: false,
         enhancement_blocked_reason: :llm_unconfigured,
         query_log_id: nil
       }}
    end
  end

  defmodule ProgressiveModalAssistantStub do
    @moduledoc false

    @spec respond(String.t(), keyword()) :: {:ok, Response.t()}
    def respond("progressive", opts) do
      if Keyword.get(opts, :llm) do
        Process.sleep(160)

        {:ok,
         %Response{
           query: "progressive",
           answer_markdown: "Enhanced modal answer",
           answer_html: "<p>Enhanced modal answer</p>",
           answer_mode: :llm,
           citations: [
             %Result{
               title: "Enhanced modal docs",
               snippet: "Enhanced modal docs snippet.",
               url: "/docs/concepts/agents",
               source_type: :docs,
               score: 0.96
             }
           ],
           retrieval_status: :success,
           llm_attempted?: true,
           llm_enhanced?: true,
           enhancement_blocked_reason: nil,
           query_log_id: nil
         }}
      else
        {:ok,
         %Response{
           query: "progressive",
           answer_markdown: "Fast modal answer",
           answer_html: "<p>Fast modal answer</p>",
           answer_mode: :deterministic,
           citations: [
             %Result{
               title: "Fast modal docs",
               snippet: "Fast modal docs snippet.",
               url: "/docs/concepts/agents",
               source_type: :docs,
               score: 0.7
             }
           ],
           retrieval_status: :success,
           llm_attempted?: false,
           llm_enhanced?: false,
           enhancement_blocked_reason: :llm_unconfigured,
           query_log_id: nil
         }}
      end
    end

    def respond(_query, _opts), do: ContentAssistantStub.respond("none", [])
  end

  defmodule ModalHarnessLive do
    use AgentJidoWeb, :live_view

    @impl true
    def render(assigns) do
      ~H"""
      <.live_component
        module={AgentJidoWeb.ContentAssistantModalComponent}
        id="primary-nav-content-assistant-modal"
        analytics_identity={
          %{
            visitor_id: "content-assistant-test-visitor",
            session_id: "content-assistant-test-session",
            path: "/docs/concepts/agents",
            referrer_host: "jido.run"
          }
        }
      />
      """
    end
  end

  setup do
    original_module = Application.get_env(:agent_jido, :content_assistant_module)
    Application.put_env(:agent_jido, :content_assistant_module, ContentAssistantStub)

    on_exit(fn ->
      if original_module do
        Application.put_env(:agent_jido, :content_assistant_module, original_module)
      else
        Application.delete_env(:agent_jido, :content_assistant_module)
      end
    end)

    :ok
  end

  test "tracks reference click events", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='submit']", assistant: %{q: "agents"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ ~s(id="primary-nav-content-assistant-modal-answer")
    end)

    view
    |> element("a[href='/docs/concepts/agents']")
    |> render_click()

    assert_eventually(fn ->
      AgentJido.Repo.exists?(
        from(e in AnalyticsEvent,
          where: e.event == "content_assistant_reference_clicked" and e.source == "content_assistant"
        )
      )
    end)

    assert_eventually(fn ->
      query_log = latest_query_log("agents")
      query_log && query_log.source == "content_assistant" && query_log.status == "success"
    end)
  end

  test "tracks no-results feedback events", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='submit']", assistant: %{q: "none"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ ~s(id="primary-nav-content-assistant-modal-empty")
    end)

    assert has_element?(view, "#primary-nav-content-assistant-modal-no-results-feedback button[title='Not helpful']")

    view
    |> form("#primary-nav-content-assistant-modal-no-results-feedback-form", feedback: %{note: "Need agent docs"})
    |> render_submit()

    assert_eventually(fn ->
      AgentJido.Repo.exists?(
        from(e in AnalyticsEvent,
          where:
            e.event == "feedback_submitted" and e.source == "content_assistant" and
              e.channel == "content_assistant_no_results"
        )
      )
    end)

    assert_eventually(fn ->
      query_log = latest_query_log("none")
      query_log && query_log.source == "content_assistant" && query_log.status == "no_results"
    end)
  end

  test "uses fast defaults for modal search execution", %{conn: conn} do
    :persistent_term.put({AssistantOptsCaptureStub, :test_pid}, self())
    original_module = Application.get_env(:agent_jido, :content_assistant_module)
    Application.put_env(:agent_jido, :content_assistant_module, AssistantOptsCaptureStub)

    on_exit(fn ->
      :persistent_term.erase({AssistantOptsCaptureStub, :test_pid})

      if original_module do
        Application.put_env(:agent_jido, :content_assistant_module, original_module)
      else
        Application.delete_env(:agent_jido, :content_assistant_module)
      end
    end)

    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='submit']", assistant: %{q: "agents"})
    |> render_submit()

    assert_receive {:modal_opts_capture, "agents", opts}, 1_000
    assert Keyword.get(opts, :llm) == nil
    assert Keyword.get(opts, :require_turnstile) == false
    assert opts |> Keyword.get(:retrieval_opts, []) |> Keyword.get(:mode) == :fulltext
    assert opts |> Keyword.get(:retrieval_opts, []) |> Keyword.get(:graph) == false
  end

  test "renders fast modal answer first, then swaps to enhanced answer in progressive mode", %{conn: conn} do
    original_module = Application.get_env(:agent_jido, :content_assistant_module)
    original_llm = Application.get_env(:arcana, :llm)

    Application.put_env(:agent_jido, :content_assistant_module, ProgressiveModalAssistantStub)
    Application.put_env(:arcana, :llm, "openai:gpt-4.1-nano")

    on_exit(fn ->
      if original_module do
        Application.put_env(:agent_jido, :content_assistant_module, original_module)
      else
        Application.delete_env(:agent_jido, :content_assistant_module)
      end

      if original_llm do
        Application.put_env(:arcana, :llm, original_llm)
      else
        Application.delete_env(:arcana, :llm)
      end
    end)

    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='submit']", assistant: %{q: "progressive"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ "Fast modal answer" and html =~ ~s(id="primary-nav-content-assistant-modal-enhancing")
    end)

    assert_eventually(fn ->
      html = render(view)
      html =~ "Enhanced modal answer" and not String.contains?(html, ~s(id="primary-nav-content-assistant-modal-enhancing"))
    end)
  end

  defp latest_query_log(query) when is_binary(query) do
    # Scope to the submitted query so this assertion is stable across files.
    AgentJido.Repo.one(
      from(q in QueryLog,
        where: q.source == "content_assistant" and q.query == ^query,
        order_by: [desc: q.inserted_at],
        limit: 1
      )
    )
  end

  defp assert_eventually(fun, attempts \\ 60)

  defp assert_eventually(fun, attempts) when attempts > 0 do
    if fun.() do
      :ok
    else
      Process.sleep(25)
      assert_eventually(fun, attempts - 1)
    end
  end

  defp assert_eventually(_fun, 0), do: flunk("expected condition to become true")
end
