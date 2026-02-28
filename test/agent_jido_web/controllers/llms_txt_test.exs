defmodule AgentJidoWeb.LLMSTxtTest do
  use AgentJidoWeb.ConnCase, async: true

  test "GET /llms.txt returns curated LLM guidance", %{conn: conn} do
    conn = get(conn, "/llms.txt")
    body = response(conn, 200)

    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/plain"
    assert body =~ "Preferred retrieval"
    assert body =~ "Accept: text/markdown"
    assert body =~ "https://agentjido.xyz/sitemap.xml"
    assert body =~ "If direct source markdown is unavailable"
  end
end
