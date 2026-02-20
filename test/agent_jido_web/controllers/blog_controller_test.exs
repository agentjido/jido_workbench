defmodule AgentJidoWeb.BlogControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  test "GET /feed returns rss xml", %{conn: conn} do
    conn = get(conn, "/feed")

    assert response(conn, 200) =~ "<rss"
    assert get_resp_header(conn, "content-type") |> hd() =~ "application/rss+xml"
  end

  test "GET /blog/search redirects to DuckDuckGo site query", %{conn: conn} do
    conn = get(conn, "/blog/search", q: "weather agent")

    assert redirected_to(conn, 302) =~ "https://duckduckgo.com/?q=weather+agent+site:"
  end
end
