defmodule AgentJidoWeb.JidoExamplesLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Examples

  @hidden_slug "budget-guardrail-agent"
  @visible_slug "workflow-coordinator"
  @ai_slug "browser-agent"

  test "draft examples are not listed on /examples", %{conn: conn} do
    hidden = Examples.get_example!(@hidden_slug, include_unpublished: true)
    {:ok, _view, html} = live(conn, "/examples")

    refute html =~ hidden.title
  end

  test "draft examples are not routable on /examples/:slug", %{conn: conn} do
    assert_raise AgentJido.Examples.NotFoundError, fn ->
      live(conn, "/examples/#{@hidden_slug}")
    end
  end

  test "taxonomy filters narrow the examples index", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/examples?scenario=coordination")

    assert html =~ "Workflow Coordinator"
    refute html =~ "Browser Agent"
  end

  test "simulated live examples are listed with a simulated badge", %{conn: conn} do
    visible = Examples.get_example!(@visible_slug)
    simulated = Examples.get_example!(@ai_slug)
    {:ok, _view, html} = live(conn, "/examples")

    assert html =~ visible.title
    assert html =~ simulated.title
    assert html =~ "simulated"
  end

  test "examples content container matches primary nav width", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/examples")

    assert html =~ ~s(class="container max-w-[1000px] mx-auto px-6 py-12")
  end
end
