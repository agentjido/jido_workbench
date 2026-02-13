defmodule AgentJidoWeb.OGImageControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  test "GET /og/features.png returns a PNG response", %{conn: conn} do
    conn = get(conn, "/og/features.png")

    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
  end

  test "GET /og/training.png returns a PNG response", %{conn: conn} do
    conn = get(conn, "/og/training.png")

    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
  end

  test "GET /og/partners.png aliases to features image route", %{conn: conn} do
    conn = get(conn, "/og/partners.png")

    assert response(conn, 200)
    assert Enum.any?(get_resp_header(conn, "content-type"), &String.starts_with?(&1, "image/png"))
  end

  test "GET /og/benchmarks.png is not routable", %{conn: conn} do
    conn = get(conn, "/og/benchmarks.png")
    assert response(conn, 404)
  end
end
