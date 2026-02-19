defmodule AgentJidoWeb.BlogControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  test "GET /blog/weather-agent renders successfully", %{conn: conn} do
    conn = get(conn, "/blog/weather-agent")

    assert html_response(conn, 200) =~ "Building a Weather Agent with Jido"
  end
end
