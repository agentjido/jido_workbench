defmodule AgentJidoWeb.MetadataTagsTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Blog

  test "GET / renders release metadata with canonical and social images", %{conn: conn} do
    conn = get(conn, "/")
    body = response(conn, 200)

    assert body =~ "A Runtime for Reliable Multi-Agent Systems · Agent Jido"

    assert_meta_content(
      body,
      "description",
      "Jido is a runtime for reliable, multi-agent systems, built on Elixir/OTP for fault isolation, concurrency, and production uptime."
    )

    assert body =~ ~r/<link rel="canonical" href="#{Regex.escape(AgentJidoWeb.Endpoint.url() <> "/")}"\s*\/?>/
    assert body =~ ~r/<meta property="og:image" content="https:\/\/agentjido\.xyz\/og\/home\.png"\s*\/?>/
    assert body =~ ~r/<meta name="twitter:image" content="https:\/\/agentjido\.xyz\/og\/home\.png"\s*\/?>/
    assert length(Regex.scan(~r/<meta name="twitter:card"/, body)) == 1
  end

  test "GET /features uses route-specific title and description", %{conn: conn} do
    conn = get(conn, "/features")
    body = response(conn, 200)

    assert body =~ "Jido Features · Agent Jido"

    assert_meta_content(
      body,
      "description",
      "Explore the architecture and runtime capabilities that make Jido reliable for production multi-agent systems."
    )

    refute body =~ "<title>Agent Jido</title>"
  end

  test "GET /blog/:slug uses post title and post description metadata", %{conn: conn} do
    post =
      Blog.all_posts()
      |> Enum.find(fn entry -> String.trim(to_string(entry.description)) != "" end)
      |> Kernel.||(Blog.all_posts() |> hd())

    conn = get(conn, "/blog/#{post.id}")
    body = response(conn, 200)

    assert body =~ "#{post.title} · Agent Jido"

    if String.trim(to_string(post.description)) != "" do
      assert_meta_content(body, "description", String.trim(post.description))
    else
      assert body =~ ~r/<meta name="description" content=".+?"\s*\/?>/
    end
  end

  test "GET /docs uses section-specific metadata", %{conn: conn} do
    conn = get(conn, "/docs")
    body = response(conn, 200)

    assert body =~ "Jido Documentation · Agent Jido"

    assert_meta_content(
      body,
      "description",
      "Reference docs and implementation guides for building reliable multi-agent systems with Jido."
    )
  end

  test "missing routes emit noindex robots, no canonical, and a single twitter card", %{conn: conn} do
    conn = get(conn, "/totally-missing-route")
    body = response(conn, 404)

    assert body =~ ~r/<meta name="robots" content="noindex,\s*nofollow"\s*\/?>/
    refute body =~ ~r/<link rel="canonical"/
    assert length(Regex.scan(~r/<meta name="twitter:card"/, body)) == 1
  end

  defp assert_meta_content(body, name, content) do
    escaped_name = Regex.escape(name)
    escaped_content = Regex.escape(content)

    assert body =~ ~r/<meta name="#{escaped_name}" content="#{escaped_content}"\s*\/?>/
  end
end
