defmodule AgentJidoWeb.BlogControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  import Ecto.Query

  alias AgentJido.QueryLogs.QueryLog

  test "GET /feed returns rss xml", %{conn: conn} do
    conn = get(conn, "/feed")

    assert response(conn, 200) =~ "<rss"
    assert get_resp_header(conn, "content-type") |> hd() =~ "application/rss+xml"
  end

  test "GET /blog/search redirects to DuckDuckGo site query", %{conn: conn} do
    conn = get(conn, "/blog/search", q: "weather agent")

    assert redirected_to(conn, 302) =~ "https://duckduckgo.com/?q=weather+agent+site:"

    query_log = AgentJido.Repo.one(from(q in QueryLog, order_by: [desc: q.inserted_at], limit: 1))
    assert query_log.source == "search"
    assert query_log.channel == "blog_duckduckgo"
    assert query_log.query == "weather agent"
  end
end
