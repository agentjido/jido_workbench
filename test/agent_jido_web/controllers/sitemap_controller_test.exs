defmodule AgentJidoWeb.SitemapControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Ecosystem
  alias AgentJido.Pages

  test "returns raw xml sitemap payload", %{conn: conn} do
    conn = get(conn, "/sitemap.xml")
    body = response(conn, 200)

    assert body =~ ~s(<?xml version="1.0" encoding="UTF-8"?>)
    assert body =~ "<urlset"
    refute body =~ "&lt;urlset"
    refute body =~ "<html"
    assert get_resp_header(conn, "content-type") |> hd() =~ "application/xml"
  end

  test "includes ecosystem package pages", %{conn: conn} do
    conn = get(conn, "/sitemap.xml")

    assert response(conn, 200)

    body = response(conn, 200)
    assert body =~ "/ecosystem"

    for pkg <- Ecosystem.public_packages() do
      assert body =~ "/ecosystem/#{pkg.id}"
    end
  end

  test "includes page URLs from the Pages system", %{conn: conn} do
    body =
      conn
      |> get("/sitemap.xml")
      |> response(200)

    # Training pages are intentionally retired from public routing
    for page <- Pages.pages_by_category(:training) do
      refute body =~ Pages.route_for(page)
    end

    assert body =~ "/features"
    refute body =~ "/partners"
    refute body =~ "/benchmarks"
  end
end
