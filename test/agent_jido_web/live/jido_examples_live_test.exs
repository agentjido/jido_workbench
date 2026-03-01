defmodule AgentJidoWeb.JidoExamplesLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  alias AgentJido.Examples

  @hidden_slug "budget-guardrail-agent"
  @visible_slug "counter-agent"
  @secondary_visible_slug "demand-tracker-agent"
  @draft_slug "browser-agent"

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

  test "examples index is simplified without browse filters", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/examples")

    refute html =~ "Browse by Taxonomy"
    refute html =~ "Wave"
    assert html =~ "Counter Agent"
    assert html =~ "Demand Tracker Agent"
    refute html =~ "Browser Agent"
  end

  test "selected live examples are listed", %{conn: conn} do
    visible = Examples.get_example!(@visible_slug)
    secondary_visible = Examples.get_example!(@secondary_visible_slug)
    {:ok, _view, html} = live(conn, "/examples")

    assert html =~ visible.title
    assert html =~ secondary_visible.title
    refute html =~ "Browser Agent"
  end

  test "admin users can see draft examples on /examples", %{conn: conn} do
    draft = Examples.get_example!(@draft_slug, include_unpublished: true)
    admin_conn = log_in_user(conn, admin_user_fixture())
    {:ok, _view, html} = live(admin_conn, "/examples")

    assert html =~ draft.title
  end

  test "admin users can open draft example routes", %{conn: conn} do
    admin_conn = log_in_user(conn, admin_user_fixture())
    {:ok, _view, html} = live(admin_conn, "/examples/#{@draft_slug}?tab=demo")

    assert html =~ "Browser Agent"
    assert html =~ "draft preview"
  end

  test "examples content container matches primary nav width", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/examples")

    assert html =~ ~s(class="container max-w-[1000px] mx-auto px-6 py-12")
  end
end
