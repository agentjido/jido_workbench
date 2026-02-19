defmodule AgentJidoWeb.TrainingRoutesTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Pages

  test "GET /training is not routable", %{conn: conn} do
    conn = get(conn, "/training")
    assert response(conn, 404)
  end

  test "GET /training/:id is not routable", %{conn: conn} do
    training_route =
      Pages.pages_by_category(:training)
      |> hd()
      |> Pages.route_for()

    conn = get(conn, training_route)
    assert response(conn, 404)
  end

  test "GET /search is not routable", %{conn: conn} do
    conn = get(conn, "/search")
    assert response(conn, 404)
  end

  test "GET /premium-support is not routable", %{conn: conn} do
    conn = get(conn, "/premium-support")
    assert response(conn, 404)
  end

  test "GET /benchmarks is not routable", %{conn: conn} do
    conn = get(conn, "/benchmarks")
    assert response(conn, 404)
  end
end
