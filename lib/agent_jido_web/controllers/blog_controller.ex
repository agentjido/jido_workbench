defmodule AgentJidoWeb.BlogController do
  @moduledoc """
  HTTP endpoints for blog-adjacent responses that are not LiveView pages.
  """
  use AgentJidoWeb, :controller

  alias AgentJido.Blog
  alias AgentJido.QueryLogs

  def search(conn, %{"q" => query}) do
    normalized_query = String.trim(to_string(query || ""))

    if normalized_query != "" do
      QueryLogs.track_query_safe(%{
        source: "search",
        channel: "blog_duckduckgo",
        query: normalized_query,
        status: "submitted",
        metadata: %{surface: "blog"}
      })
    end

    site_url = AgentJidoWeb.Endpoint.url()
    # Extract hostname from the URL without the protocol
    hostname = URI.parse(site_url).host || "jido.app"
    search_url = "https://duckduckgo.com/?q=#{URI.encode_www_form(normalized_query)}+site:#{hostname}"

    conn
    |> redirect(external: search_url)
  end

  def search(conn, _params) do
    redirect(conn, to: ~p"/blog")
  end

  def feed(conn, _params) do
    posts = Blog.all_posts()
    feed_xml = Phoenix.Template.render_to_string(AgentJidoWeb.BlogHTML, "feed", "xml", posts: posts)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, feed_xml)
  end
end
