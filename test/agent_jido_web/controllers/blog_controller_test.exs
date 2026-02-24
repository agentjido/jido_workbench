defmodule AgentJidoWeb.BlogControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Blog

  test "GET /feed returns rss xml", %{conn: conn} do
    conn = get(conn, "/feed")

    body = response(conn, 200)
    first_post = Blog.all_posts() |> hd()

    assert body =~ "<rss"
    assert body =~ "<channel>"
    assert body =~ "/blog/#{first_post.id}"
    refute body =~ "/blog/announcing-req_llm-1_0"
    refute body =~ "/blog/introducing-req_llm"
    refute body =~ "/blog/jido_signal"
    assert get_resp_header(conn, "content-type") |> hd() =~ "application/rss+xml"
  end
end
