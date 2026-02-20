defmodule AgentJidoWeb.JidoFeaturesLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders features landing content", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/features")

    assert html =~ "RUNTIME-FIRST CAPABILITIES"
    assert html =~ "How capabilities stack"
    assert html =~ "Category explorer"
    assert html =~ "Audience quick paths"
    assert html =~ "Proof jump panel"
    assert html =~ "Adoption guidance by maturity"
    assert html =~ ~s(href="/docs/getting-started")
  end

  test "legacy partners route returns branded 404 page", %{conn: conn} do
    conn = get(conn, "/partners")
    body = response(conn, 404)

    assert body =~ "Page not found"
    assert body =~ "/partners"
  end
end
