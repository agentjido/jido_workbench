defmodule AgentJidoWeb.JidoExampleLiveTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias AgentJido.Examples

  @endpoint AgentJidoWeb.Endpoint

  setup_all do
    ensure_started(:telemetry)
    ensure_started(:phoenix_pubsub)
    ensure_started(:phoenix)
    ensure_started(:phoenix_live_view)
    ensure_started(:jido_action)

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

  describe "/examples/browser-agent" do
    test "is hidden from public visitors", %{conn: conn} do
      assert_raise AgentJido.Examples.NotFoundError, fn ->
        live(conn, "/examples/browser-agent?tab=demo")
      end
    end
  end
end
