defmodule AgentJidoWeb.TrainingRoutesTest do
  use AgentJidoWeb.ConnCase, async: true

  test "GET /benchmarks is not routable", %{conn: conn} do
    conn = get(conn, "/benchmarks")
    assert response(conn, 404)
  end
end
