defmodule AgentJidoWeb.JidoEcosystemPackageMatrixLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "ecosystem matrix route redirects permanently to the compare anchor", %{conn: conn} do
    redirected_conn = get(conn, "/ecosystem/matrix")
    assert redirected_to(redirected_conn, 301) == "/ecosystem#compare"
  end

  test "legacy package-matrix route redirects permanently to the compare anchor", %{conn: conn} do
    redirected_conn = get(conn, "/ecosystem/package-matrix")
    assert redirected_to(redirected_conn, 301) == "/ecosystem#compare"
  end

  test "legacy matrix markdown route redirects to the ecosystem markdown compare anchor", %{conn: conn} do
    redirected_conn = get(conn, "/ecosystem/matrix.md")
    assert redirected_to(redirected_conn, 301) == "/ecosystem.md#compare"
  end

  test "legacy package-matrix markdown route redirects to the ecosystem markdown compare anchor", %{conn: conn} do
    redirected_conn = get(conn, "/ecosystem/package-matrix.md")
    assert redirected_to(redirected_conn, 301) == "/ecosystem.md#compare"
  end

  test "representative package detail pages still resolve via /ecosystem/:id", %{conn: conn} do
    Enum.each(~w(jido jido_action), fn package_id ->
      {:ok, _view, html} = live(recycle(conn), "/ecosystem/#{package_id}")

      assert html =~ "FULL OVERVIEW"
      refute html =~ "Ecosystem Package Matrix"
    end)
  end
end
