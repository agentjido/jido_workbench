defmodule AgentJidoWeb.BlogControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  test "GET /feed returns rss xml", %{conn: conn} do
    conn = get(conn, "/feed")

    assert response(conn, 200) =~ "<rss"
    assert get_resp_header(conn, "content-type") |> hd() =~ "application/rss+xml"
  end
end
