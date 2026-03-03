defmodule AgentJidoWeb.LLMResponsePlugTest do
  use AgentJidoWeb.ConnCase, async: true

  @moduletag :flaky

  test "html response includes LLM discovery headers for supported routes", %{conn: conn} do
    conn = get(conn, "/docs")
    assert response(conn, 200)

    vary = get_resp_header(conn, "vary") |> List.first()
    link = get_resp_header(conn, "link") |> List.first()

    assert vary =~ "Accept"
    assert link =~ ~s(</llms.txt>; rel="alternate"; type="text/plain")
    assert link =~ "<#{AgentJidoWeb.Endpoint.url()}/docs.md>; rel=\"alternate\"; type=\"text/markdown\""
  end

  test "markdown negotiation returns source markdown with discovery and SEO headers", %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "text/markdown")
      |> get("/docs")

    body = response(conn, 200)
    vary = get_resp_header(conn, "vary") |> List.first()
    link = get_resp_header(conn, "link") |> List.first()

    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/markdown"
    assert get_resp_header(conn, "x-robots-tag") == ["noindex"]
    assert vary =~ "Accept"
    assert link =~ ~s(</llms.txt>; rel="alternate"; type="text/plain")
    assert link =~ "<#{AgentJidoWeb.Endpoint.url()}/docs.md>; rel=\"alternate\"; type=\"text/markdown\""
    assert link =~ "<#{AgentJidoWeb.Endpoint.url()}/docs>; rel=\"canonical\""
    assert body =~ "title: \"Documentation\""
    assert body =~ "## Find what you need"
  end

  test "explicit .md routes return markdown without accept header", %{conn: conn} do
    conn = get(conn, "/docs.md")

    body = response(conn, 200)
    link = get_resp_header(conn, "link") |> List.first()

    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/markdown"
    assert get_resp_header(conn, "x-robots-tag") == ["noindex"]
    assert link =~ "<#{AgentJidoWeb.Endpoint.url()}/docs.md>; rel=\"alternate\"; type=\"text/markdown\""
    assert link =~ "<#{AgentJidoWeb.Endpoint.url()}/docs>; rel=\"canonical\""
    assert body =~ "title: \"Documentation\""
  end

  test "legacy docs redirects remain unchanged even with markdown accept header", %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "text/markdown")
      |> get("/docs/core-concepts")

    assert redirected_to(conn, 301) == "/docs/concepts"
  end

  test "excluded routes do not negotiate markdown", %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "text/markdown")
      |> get("/sitemap.xml")

    assert response(conn, 200)
    assert get_resp_header(conn, "content-type") |> List.first() =~ "application/xml"
  end

  test "auth routes do not negotiate markdown", %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "text/markdown")
      |> get("/users/log-in")

    assert response(conn, 200)
    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/html"
  end

  test "supported routes without direct source return deterministic markdown fallback", %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "text/markdown")
      |> get("/features")

    body = response(conn, 200)
    link = get_resp_header(conn, "link") |> List.first()

    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/markdown"
    assert get_resp_header(conn, "x-robots-tag") == ["noindex"]
    assert link =~ "<#{AgentJidoWeb.Endpoint.url()}/features.md>; rel=\"alternate\"; type=\"text/markdown\""
    assert link =~ "<#{AgentJidoWeb.Endpoint.url()}/features>; rel=\"canonical\""
    assert body =~ "# Jido Features"
    assert body =~ "Canonical URL: #{AgentJidoWeb.Endpoint.url()}/features"
    refute body =~ "Markdown URL:"
  end
end
