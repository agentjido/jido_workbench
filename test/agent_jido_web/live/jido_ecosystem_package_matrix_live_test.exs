defmodule AgentJidoWeb.JidoEcosystemPackageMatrixLiveTest do
  use AgentJidoWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias AgentJido.Ecosystem

  test "renders package matrix page on static route", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/ecosystem/package-matrix")

    assert html =~ "Ecosystem Package Matrix"
    assert html =~ "ADOPTION ORDER"
    assert html =~ "SHOW UNSTABLE"
    assert html =~ ~s(href="/ecosystem/jido")
    refute html =~ ~s(href="/ecosystem/jido_ai")
  end

  test "toggle reveals unstable curated packages", %{conn: conn} do
    {:ok, view, html} = live(conn, "/ecosystem/package-matrix")

    unstable_curated_id =
      Ecosystem.public_packages()
      |> Enum.filter(&(&1.id in ~w(ash_jido jido_runic jido_memory jido_otel jido_studio jido_messaging jido_behaviortree)))
      |> Enum.filter(&(&1.maturity in [:experimental, :planned]))
      |> Enum.map(& &1.id)
      |> List.first()

    case unstable_curated_id do
      nil ->
        refute html =~ "HIDE UNSTABLE"

      id ->
        refute html =~ ~s(href="/ecosystem/#{id}")
        html = view |> element("button[phx-click=toggle_unstable]") |> render_click()
        assert html =~ "HIDE UNSTABLE"
        assert html =~ ~s(href="/ecosystem/#{id}")
    end
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
