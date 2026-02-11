defmodule AgentJidoWeb.JidoEcosystemPackageLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Ecosystem

  test "renders enriched landing sections for jido_ai", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/ecosystem/jido_ai")

    assert html =~ "AT A GLANCE"
    assert html =~ "IMPORTANT PACKAGES"
    assert html =~ "HOW MODULES FIT TOGETHER"
    assert html =~ "Start with a single ask/await workflow"
    assert html =~ "Ask/Await API"
    assert html =~ "select strategy"

    assert html =~ ~s(href="/ecosystem/jido")
    assert html =~ ~s(href="/ecosystem/req_llm")
    assert html =~ ~s(href="https://hexdocs.pm/jido")
    assert html =~ "back to ecosystem"
  end

  test "falls back to key features and deps for package without landing metadata", %{conn: conn} do
    package = Ecosystem.get_package!("jido")

    {:ok, _view, html} = live(conn, "/ecosystem/jido")

    assert html =~ package.title
    assert html =~ package.tagline
    assert html =~ "AT A GLANCE"
    assert html =~ "MAJOR COMPONENTS"
    assert html =~ "Jido.Plan"
    assert html =~ ~s(href="https://hexdocs.pm/jido/Jido.Plan.html")
    assert html =~ "Pure functional agent architecture"
    assert html =~ "IMPORTANT PACKAGES"
    assert html =~ ~s(href="/ecosystem/jido_action")
    assert html =~ ~s(href="/ecosystem/jido_signal")
    refute html =~ "HOW MODULES FIT TOGETHER"
    assert html =~ "back to ecosystem"
  end
end
