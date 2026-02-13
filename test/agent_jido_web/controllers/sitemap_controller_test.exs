defmodule AgentJidoWeb.SitemapControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Ecosystem
  alias AgentJido.Pages

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

    # Training pages should be included
    for page <- Pages.pages_by_category(:training) do
      assert body =~ Pages.route_for(page)
    end

    assert body =~ "/features"
    refute body =~ "/partners"
    refute body =~ "/benchmarks"
  end
end
