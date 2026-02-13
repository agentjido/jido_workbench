defmodule AgentJidoWeb.JidoFeaturesLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders features landing content", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/features")

    assert html =~ "PLATFORM FEATURES"
    assert html =~ "Core Runtime"
    assert html =~ "Developer Integration"
    assert html =~ "Production Readiness"
    assert html =~ "BEAM-Native Agent Model"
    assert html =~ "Schema-Validated Actions"
    assert html =~ ~s(href="/training")
  end

  test "legacy partners route serves features page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/partners")
    assert html =~ "PLATFORM FEATURES"
  end
end
