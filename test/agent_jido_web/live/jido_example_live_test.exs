defmodule AgentJidoWeb.JidoExampleLiveTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias AgentJido.Examples

  @endpoint AgentJidoWeb.Endpoint
  @new_simulated_showcase_examples [
    {"runic-ai-research-studio-step-mode", "Runic AI Research Studio Step Mode"},
    {"runic-adaptive-researcher", "Runic Adaptive Researcher"},
    {"runic-structured-llm-branching", "Runic Structured LLM Branching"},
    {"runic-delegating-orchestrator", "Runic Delegating Orchestrator"},
    {"jido-ai-actions-runtime-demos", "Jido.AI Actions Runtime Demos"},
    {"jido-ai-weather-multi-turn-context", "Jido.AI Weather Multi-Turn Context"},
    {"jido-ai-task-execution-workflow", "Jido.AI Task Execution Workflow"},
    {"jido-ai-skills-runtime-foundations", "Jido.AI Skills Runtime Foundations"},
    {"jido-ai-skills-multi-agent-orchestration", "Jido.AI Skills Multi-Agent Orchestration"},
    {"jido-ai-weather-reasoning-strategy-suite", "Jido.AI Weather Reasoning Strategy Suite"},
    {"jido-ai-operational-agents-pack", "Jido.AI Operational Agents Pack"}
  ]

  setup_all do
    ensure_started(:telemetry)
    ensure_started(:phoenix_pubsub)
    ensure_started(:phoenix)
    ensure_started(:phoenix_live_view)
    ensure_started(:jido_action)
    ensure_started(:jido_browser)

    if Process.whereis(AgentJido.PubSub) == nil do
      start_supervised!({Phoenix.PubSub, name: AgentJido.PubSub})
    end

    if Process.whereis(AgentJidoWeb.Endpoint) == nil do
      start_supervised!(AgentJidoWeb.Endpoint)
    end

    :ok
  end

  setup do
    {:ok, conn: build_conn()}
  end

  defp ensure_started(app) do
    case Application.ensure_all_started(app) do
      {:ok, _apps} -> :ok
      {:error, {:already_started, _app}} -> :ok
      {:error, reason} -> raise "failed to start #{inspect(app)}: #{inspect(reason)}"
    end
  end

  describe "/examples/address-normalization-agent" do
    test "renders explanation tab", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/examples/address-normalization-agent?tab=explanation")

      assert html =~ "Address Normalization Agent"
      assert html =~ "Action contracts and validation"
      assert html =~ "Story Link"
    end

    test "renders source tab", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/examples/address-normalization-agent?tab=source")

      assert html =~ "address_normalization_agent.ex"
      assert html =~ "execute_action.ex"
      assert html =~ "reset_action.ex"
      assert html =~ "address_normalization_agent_live.ex"
      refute html =~ "file="
    end

    test "source tab uses clean indexed URL params", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/examples/address-normalization-agent?tab=source")

      view
      |> element("a", "execute_action.ex")
      |> render_click()

      patched = assert_patch(view)
      assert URI.parse(patched).path == "/examples/address-normalization-agent"
      assert URI.parse(patched).query |> URI.decode_query() == %{"source" => "2", "tab" => "source"}

      html = render(view)
      assert html =~ "tab=source"
      assert html =~ "source=2"
      refute html =~ "file="
    end

    test "renders demo tab and validates interaction flow", %{conn: conn} do
      {:ok, view, html} = live(conn, "/examples/address-normalization-agent?tab=demo")

      assert html =~ "Address Normalization Agent"
      assert html =~ "Action Contract"

      demo_view = find_live_child(view, "demo-address-normalization-agent")

      html =
        demo_view
        |> element("#address-normalization-demo button[phx-click='run_valid_sample']")
        |> render_click()

      assert html =~ "123 Main St, San Francisco, CA 94105, US"
      assert html =~ "successful runs: 1"

      html =
        demo_view
        |> element("#address-normalization-demo button[phx-click='run_invalid_sample']")
        |> render_click()

      assert html =~ "Action contract rejected the payload."
    end

    test "example registry metadata resolves source files", %{conn: _conn} do
      example = Examples.get_example!("address-normalization-agent")

      assert example.title == "Address Normalization Agent"
      assert example.live_view_module == "AgentJidoWeb.Examples.AddressNormalizationAgentLive"

      assert example.source_files == [
               "lib/agent_jido/demos/address_normalization/address_normalization_agent.ex",
               "lib/agent_jido/demos/address_normalization/actions/execute_action.ex",
               "lib/agent_jido/demos/address_normalization/actions/reset_action.ex",
               "lib/agent_jido_web/examples/address_normalization_agent_live.ex"
             ]

      assert Enum.map(example.sources, & &1.path) == example.source_files
    end
  end

  describe "/examples/counter-agent" do
    test "renders related guides and livebooks", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/examples/counter-agent?tab=explanation")

      assert html =~ "Related guides and notebooks"
      assert html =~ "/docs/getting-started/first-agent"
      assert html =~ "/docs/concepts/actions"
      assert html =~ "/docs/learn/first-workflow"
      assert html =~ "livebook.dev/run?url="
    end

    test "tabs patch cleanly for history navigation", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/examples/counter-agent?tab=explanation")

      view
      |> element("a", "Interactive Demo")
      |> render_click()

      assert_patch(view, "/examples/counter-agent?tab=demo")

      view
      |> element("a", "Source Code")
      |> render_click()

      patched = assert_patch(view)
      assert URI.parse(patched).path == "/examples/counter-agent"
      assert URI.parse(patched).query |> URI.decode_query() == %{"source" => "1", "tab" => "source"}
    end
  end

  describe "/examples/runic-ai-research-studio" do
    test "renders explanation tab with workflow and source references", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/examples/runic-ai-research-studio?tab=explanation")

      assert html =~ "Runic AI Research Studio"
      assert html =~ "PlanQueries"
      assert html =~ "EditAndAssemble"
      assert html =~ "studio_demo.exs"
      assert html =~ "orchestrator_agent.ex"
    end

    test "demo tab runs deterministic simulated workflow trace", %{conn: conn} do
      {:ok, view, html} = live(conn, "/examples/runic-ai-research-studio?tab=demo")

      assert html =~ "Runic AI Research Studio"
      assert html =~ "Simulated demo"

      demo_view = find_live_child(view, "demo-runic-ai-research-studio")

      demo_view
      |> element("#simulated-showcase-demo-runic-ai-research-studio button[phx-click='run_demo']")
      |> render_click()

      Enum.each(1..6, fn _step ->
        send(demo_view.pid, :advance_step)
      end)

      final_html = render(demo_view)

      assert final_html =~ "Simulated Result"
      assert final_html =~ "PlanQueries"
      assert final_html =~ "simulated:haiku"
    end
  end

  describe "/examples/jido-ai-browser-web-workflow" do
    test "renders explanation tab with live-browser requirements and fallback guidance", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/examples/jido-ai-browser-web-workflow?tab=explanation")

      assert html =~ "Jido Browser Docs Scout Agent"
      assert html =~ "agentjido/jido_browser"
      assert html =~ "Jido.Browser.Plugin"
      assert html =~ "jido_browser.install --if-missing"
      assert html =~ "No API keys or browser binaries are required for this site demo."
      assert html =~ "without refetching the URL"
      assert html =~ "keep the simulated adapter wired in dev/test"
    end

    test "renders source tab for the dedicated browser example", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/examples/jido-ai-browser-web-workflow?tab=source")

      assert html =~ "browser_docs_scout_agent.ex"
      assert html =~ "browser_actions.ex"
      assert html =~ "simulated_adapter.ex"
      assert html =~ "browser_docs_scout_agent_live.ex"
    end

    test "demo tab runs the deterministic browser flow", %{conn: conn} do
      {:ok, view, html} = live(conn, "/examples/jido-ai-browser-web-workflow?tab=demo")

      assert html =~ "Jido Browser Docs Scout Agent"
      assert html =~ "Simulated demo"

      demo_view = find_live_child(view, "demo-jido-ai-browser-web-workflow")

      html =
        demo_view
        |> element("#browser-docs-scout-demo button[phx-click='open_intro']")
        |> render_click()

      assert html =~ "Jido Browser Plugin Guide"
      assert html =~ "session:"

      html =
        demo_view
        |> element("#browser-docs-scout-demo button[phx-click='extract_article']")
        |> render_click()

      assert html =~ "chars"
      assert html =~ "Jido.Browser.Plugin"

      html =
        demo_view
        |> element("#browser-docs-scout-demo button[phx-click='follow_link']")
        |> render_click()

      assert html =~ "Testing Browser Agents"
      assert html =~ "3 step(s)"

      html =
        demo_view
        |> element("#browser-docs-scout-demo button[phx-click='capture_screenshot']")
        |> render_click()

      assert html =~ "data:image/png;base64,"

      html =
        demo_view
        |> element("#browser-docs-scout-demo button[phx-click='reset_demo']")
        |> render_click()

      assert html =~ "No docs page opened yet"
      assert html =~ "session: idle"
    end

    test "example registry metadata resolves new browser source files", %{conn: _conn} do
      example = Examples.get_example!("jido-ai-browser-web-workflow")

      assert example.title == "Jido Browser Docs Scout Agent"
      assert example.live_view_module == "AgentJidoWeb.Examples.BrowserDocsScoutAgentLive"

      assert example.source_files == [
               "lib/agent_jido/demos/browser_docs_scout/browser_docs_scout_agent.ex",
               "lib/agent_jido/demos/browser_docs_scout/browser_actions.ex",
               "lib/agent_jido/demos/browser_docs_scout/simulated_adapter.ex",
               "lib/agent_jido_web/examples/browser_docs_scout_agent_live.ex"
             ]

      assert Enum.map(example.sources, & &1.path) == example.source_files
    end
  end

  describe "new simulated showcase examples" do
    test "render explanation tabs", %{conn: conn} do
      Enum.each(@new_simulated_showcase_examples, fn {slug, title} ->
        {:ok, _view, html} = live(conn, "/examples/#{slug}?tab=explanation")
        assert html =~ title
        assert html =~ "simulated"
      end)
    end

    test "run deterministic interactive traces", %{conn: conn} do
      Enum.each(@new_simulated_showcase_examples, fn {slug, title} ->
        {:ok, view, html} = live(conn, "/examples/#{slug}?tab=demo")
        assert html =~ title
        assert html =~ "Simulated demo"

        demo_view = find_live_child(view, "demo-#{slug}")

        demo_view
        |> element("#simulated-showcase-demo-#{slug} button[phx-click='run_demo']")
        |> render_click()

        Enum.each(1..8, fn _ -> send(demo_view.pid, :advance_step) end)

        final_html = render(demo_view)
        assert final_html =~ "Simulated Result"
        assert final_html =~ "simulated:"
      end)
    end
  end

  describe "/examples/coding-assistant" do
    test "is hidden from public visitors", %{conn: conn} do
      assert_raise AgentJido.Examples.NotFoundError, fn ->
        live(conn, "/examples/coding-assistant?tab=demo")
      end
    end
  end
end
