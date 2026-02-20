defmodule AgentJidoWeb.OGImageControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Blog
  alias AgentJido.Ecosystem
  alias AgentJido.Examples
  alias AgentJido.Pages

  test "GET /og/render/home returns a PNG response", %{conn: conn} do
    conn = get(conn, "/og/render/home")
    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
    assert get_resp_header(conn, "etag") != []
    assert get_resp_header(conn, "cache-control") == ["public, max-age=3600"]
  end

  test "GET /og/render/blog/:slug returns a PNG response for a valid post", %{conn: conn} do
    slug = Blog.all_posts() |> hd() |> Map.get(:id)
    conn = get(conn, "/og/render/blog/#{slug}")

    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
  end

  test "GET /og/render/docs/... returns a PNG response", %{conn: conn} do
    docs_path =
      Pages.pages_by_category(:docs)
      |> Enum.map(&Pages.route_for/1)
      |> Enum.find(&(&1 != "/docs"))
      |> Kernel.||("/docs")

    conn = get(conn, "/og/render" <> docs_path)

    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
  end

  test "GET /og/render/examples/:slug returns a PNG response", %{conn: conn} do
    slug = Examples.all_examples() |> hd() |> Map.get(:slug)
    conn = get(conn, "/og/render/examples/#{slug}")

    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
  end

  test "GET /og/render/ecosystem/:id returns a PNG response", %{conn: conn} do
    id = Ecosystem.public_packages() |> hd() |> Map.get(:id)
    conn = get(conn, "/og/render/ecosystem/#{id}")

    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
  end

  test "unknown render paths return fallback PNG (200)", %{conn: conn} do
    conn = get(conn, "/og/render/totally/missing/path")

    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
  end

  test "etag conditional request returns 304 when unchanged", %{conn: conn} do
    conn = get(conn, "/og/render/home")
    etag = conn |> get_resp_header("etag") |> List.first()

    assert is_binary(etag)

    conn =
      build_conn()
      |> put_req_header("if-none-match", etag)
      |> get("/og/render/home")

    assert response(conn, 304) == ""
    assert get_resp_header(conn, "etag") == [etag]
  end

  test "legacy OG endpoints are no longer routable", %{conn: _conn} do
    slug = Blog.all_posts() |> hd() |> Map.get(:id)

    for path <- [
          "/og/default.png",
          "/og/home.png",
          "/og/ecosystem.png",
          "/og/getting-started.png",
          "/og/examples.png",
          "/og/features.png",
          "/og/partners.png",
          "/og/training.png",
          "/og/docs.png",
          "/og/blog.png",
          "/og/blog/#{slug}"
        ] do
      assert response(get(build_conn(), path), 404)
    end
  end
end
