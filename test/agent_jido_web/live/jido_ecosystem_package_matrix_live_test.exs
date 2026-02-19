defmodule AgentJidoWeb.JidoEcosystemPackageMatrixLiveTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest

  import Phoenix.LiveViewTest

  @endpoint AgentJidoWeb.Endpoint

  setup do
    {:ok, _} = Application.ensure_all_started(:plug)
    {:ok, _} = Application.ensure_all_started(:plug_crypto)
    {:ok, _} = Application.ensure_all_started(:telemetry)
    {:ok, _pid} = start_supervised(AgentJidoWeb.Endpoint)
    :ok
  end

  test "renders package matrix page on static route" do
    conn = build_conn()

    {:ok, _view, html} = live(conn, "/ecosystem/package-matrix")

    assert html =~ "Ecosystem Package Matrix"
    assert html =~ "ADOPTION ORDER"
    assert html =~ ~s(href="/ecosystem/jido")
    assert html =~ ~s(href="/ecosystem/jido_ai")
  end

  test "static package-matrix path wins over /ecosystem/:id route" do
    conn = build_conn()

    {:ok, _view, html} = live(conn, "/ecosystem/package-matrix")

    assert html =~ "PACKAGE MATRIX"
    refute html =~ "FULL OVERVIEW"
  end

  test "representative package detail pages still resolve via /ecosystem/:id" do
    for package_id <- ~w(jido jido_ai) do
      conn = build_conn()
      {:ok, _view, html} = live(conn, "/ecosystem/#{package_id}")

      assert html =~ "FULL OVERVIEW"
      refute html =~ "Ecosystem Package Matrix"
    end
  end
end
