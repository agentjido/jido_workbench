defmodule AgentJidoWeb.JidoEcosystemPackageMatrixLiveTest do
  use AgentJidoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "renders package matrix page on static route", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/ecosystem/package-matrix")

    assert html =~ "Ecosystem Package Matrix"
    assert html =~ "ADOPTION ORDER"
    assert html =~ ~s(href="/ecosystem/jido")
    refute html =~ ~s(href="/ecosystem/jido_ai")
  end

  test "static package-matrix path wins over /ecosystem/:id route", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/ecosystem/package-matrix")

    assert html =~ "PACKAGE MATRIX"
    refute html =~ "FULL OVERVIEW"
  end

  test "representative package detail pages still resolve via /ecosystem/:id", %{conn: conn} do
    Enum.each(~w(jido jido_action), fn package_id ->
      {:ok, _view, html} = live(recycle(conn), "/ecosystem/#{package_id}")

      assert html =~ "FULL OVERVIEW"
      refute html =~ "Ecosystem Package Matrix"
    end)
  end
end
