defmodule AgentJidoWeb.JidoEcosystemLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Ecosystem

  test "renders ecosystem package directory and links all public packages", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/ecosystem")

    assert html =~ "PACKAGE ECOSYSTEM"
    assert html =~ "LAYERED ECOSYSTEM MAP"
    assert html =~ "FOUNDATION LAYER"
    assert html =~ "APPLICATION LAYER"
    assert html =~ "ALL PACKAGES"
    refute html =~ "DEPENDENCY GRAPH"
    refute html =~ "jido_coder"

    for pkg <- Ecosystem.public_packages() do
      assert html =~ pkg.name
      assert html =~ ~s(href="/ecosystem/#{pkg.id}")
    end
  end

  test "shows public package count in page stats", %{conn: conn} do
    package_count = length(Ecosystem.public_packages())

    {:ok, _view, html} = live(conn, "/ecosystem")

    assert html =~ ~r/#{package_count}\s*<\/span>\s*<span class="text-muted-foreground text-xs">packages<\/span>/
  end
end
