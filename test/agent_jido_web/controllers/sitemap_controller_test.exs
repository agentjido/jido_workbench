defmodule AgentJidoWeb.SitemapControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Ecosystem
  alias AgentJido.Training

  test "includes ecosystem package pages", %{conn: conn} do
    conn = get(conn, "/sitemap.xml")

    assert response(conn, 200)

    body = response(conn, 200)
    assert body =~ "/ecosystem"

    for pkg <- Ecosystem.public_packages() do
      assert body =~ "/ecosystem/#{pkg.id}"
    end
  end

  test "includes training URLs and excludes benchmarks", %{conn: conn} do
    body =
      conn
      |> get("/sitemap.xml")
      |> response(200)

    assert body =~ "/training"

    for module <- Training.all_modules() do
      assert body =~ "/training/#{module.slug}"
    end

    assert body =~ "/features"
    refute body =~ "/partners"
    refute body =~ "/benchmarks"
  end
end
