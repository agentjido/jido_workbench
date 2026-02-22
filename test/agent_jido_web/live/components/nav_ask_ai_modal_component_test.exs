defmodule AgentJidoWeb.NavAskAiModalComponentTest do
  use AgentJidoWeb.ConnCase, async: false

  import Ecto.Query
  import Phoenix.LiveViewTest

  alias AgentJido.QueryLogs.QueryLog
  alias AgentJido.Search.Result

  defmodule SearchStub do
    def query_with_status(_query, _opts) do
      {:ok,
       [
         %Result{
           title: "Agents",
           snippet: "Agents model state and command boundaries.",
           url: "/docs/concepts/agents",
           source_type: :docs,
           score: 0.95
         }
       ], :success}
    end
  end

  defmodule TurnstileStub do
    def verify("good-token", _remote_ip), do: :ok
    def verify(_token, _remote_ip), do: {:error, :missing_token}
  end

  defmodule AskAiStub do
    def summarize(_query, _citations), do: {:ok, "Stubbed LLM answer.", :llm}
  end

  defmodule AskAiQuotaFallbackStub do
    def summarize(_query, _citations), do: {:ok, "Stubbed fallback answer.", :quota_fallback}
  end

  defmodule ModalHarnessLive do
    use AgentJidoWeb, :live_view

    @impl true
    def render(assigns) do
      ~H"""
      <.live_component module={AgentJidoWeb.NavAskAiModalComponent} id="primary-nav-ask-ai-modal" />
      """
    end
  end

  setup do
    original_search = Application.get_env(:agent_jido, :ask_ai_search_module)
    original_turnstile = Application.get_env(:agent_jido, :ask_ai_turnstile_module)
    original_ask_ai = Application.get_env(:agent_jido, :ask_ai_module)
    original_cfg = Application.get_env(:agent_jido, AgentJido.AskAi)

    Application.put_env(:agent_jido, :ask_ai_search_module, SearchStub)
    Application.put_env(:agent_jido, :ask_ai_turnstile_module, TurnstileStub)
    Application.put_env(:agent_jido, :ask_ai_module, AskAiStub)

    Application.put_env(:agent_jido, AgentJido.AskAi,
      require_turnstile: true,
      turnstile_site_key: "site-key",
      turnstile_secret_key: "secret"
    )

    on_exit(fn ->
      restore_env(:ask_ai_search_module, original_search)
      restore_env(:ask_ai_turnstile_module, original_turnstile)
      restore_env(:ask_ai_module, original_ask_ai)
      restore_env(AgentJido.AskAi, original_cfg)
    end)

    :ok
  end

  test "submit without turnstile token shows challenge-required state", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='ask']", ask: %{q: "What is an agent?", turnstile_token: ""})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ ~s(id="primary-nav-ask-ai-modal-challenge") and html =~ "Complete the verification challenge"
    end)

    query_log = latest_query_log()
    assert query_log.source == "ask_ai"
    assert query_log.status == "challenge"
    assert query_log.query == "What is an agent?"
  end

  test "submit with valid turnstile token shows normal answer flow", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='ask']", ask: %{q: "What is an agent?", turnstile_token: "good-token"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ ~s(id="primary-nav-ask-ai-modal-answer") and html =~ "Stubbed LLM answer."
    end)

    assert_eventually(fn ->
      query_log = latest_query_log()
      query_log && query_log.source == "ask_ai" && query_log.status == "success" && query_log.results_count == 1
    end)
  end

  test "quota fallback shows answer with fallback banner", %{conn: conn} do
    Application.put_env(:agent_jido, :ask_ai_module, AskAiQuotaFallbackStub)
    {:ok, view, _html} = live_isolated(conn, ModalHarnessLive)

    view
    |> form("form[phx-submit='ask']", ask: %{q: "What is an agent?", turnstile_token: "good-token"})
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)

      html =~ ~s(id="primary-nav-ask-ai-modal-answer") and
        html =~ ~s(id="primary-nav-ask-ai-modal-fallback-banner") and
        html =~ "Stubbed fallback answer."
    end)

    assert_eventually(fn ->
      query_log = latest_query_log()
      query_log && query_log.source == "ask_ai" && query_log.status == "success" && query_log.results_count == 1
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

  defp assert_eventually(_fun, 0), do: flunk("expected condition to become true")

  defp restore_env(key, nil), do: Application.delete_env(:agent_jido, key)
  defp restore_env(key, value), do: Application.put_env(:agent_jido, key, value)

  defp latest_query_log do
    AgentJido.Repo.one(from(q in QueryLog, order_by: [desc: q.inserted_at], limit: 1))
  end
end
