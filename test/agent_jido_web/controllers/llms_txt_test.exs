defmodule AgentJidoWeb.LLMSTxtTest do
  use AgentJidoWeb.ConnCase, async: true

  test "GET /llms.txt returns curated LLM guidance", %{conn: conn} do
    conn = get(conn, "/llms.txt")
    body = response(conn, 200)
    endpoint_url = AgentJidoWeb.Endpoint.url()

    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/plain"
    assert body =~ "Preferred retrieval"
    assert body =~ "Append `.md` to canonical public routes"
    assert body =~ "#{endpoint_url}/docs/reference/why-not-just-a-genserver.md"
    assert body =~ "Accept: text/markdown"
    assert body =~ "#{endpoint_url}/sitemap.xml"
    assert body =~ "If source markdown is unavailable"
  end
end
