defmodule AgentJidoWeb.TrainingRoutesTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Pages

  test "GET /training is not routable", %{conn: conn} do
    conn = get(conn, "/training")
    body = response(conn, 404)
    assert body =~ "Page not found"
    assert body =~ "/training"
    assert body =~ "training routes"
  end

  test "GET /training/:id is not routable", %{conn: conn} do
    training_route =
      Pages.pages_by_category(:training)
      |> hd()
      |> Pages.route_for()

    conn = get(conn, training_route)
    body = response(conn, 404)
    assert body =~ "Page not found"
    assert body =~ training_route
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

  test "unknown routes render the branded 404 page", %{conn: conn} do
    conn = get(conn, "/totally-missing-route")
    body = response(conn, 404)

    assert body =~ "Page not found"
    assert body =~ "/totally-missing-route"
    assert body =~ "GET BUILDING"
  end
end
