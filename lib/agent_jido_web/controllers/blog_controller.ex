defmodule AgentJidoWeb.BlogController do
  @moduledoc """
  HTTP endpoints for blog-adjacent responses that are not LiveView pages.
  """
  use AgentJidoWeb, :controller

  alias AgentJido.Analytics
  alias AgentJido.Blog
  alias AgentJido.QueryLogs

  def search(conn, %{"q" => query}) do
    normalized_query = String.trim(to_string(query || ""))

    if normalized_query != "" do
      query_log =
        QueryLogs.track_query_safe(conn.assigns[:current_scope], conn.assigns[:analytics_identity], %{
          source: "search",
          channel: "blog_duckduckgo",
          query: normalized_query,
          status: "submitted",
          path: conn.request_path,
          referrer_host: get_in(conn.assigns, [:analytics_identity, :referrer_host]),
          metadata: %{surface: "blog"}
        })

      Analytics.track_event_safe(conn.assigns[:current_scope], %{
        event: "search_submitted",
        source: "search",
        channel: "blog_duckduckgo",
        path: conn.request_path,
        query_log_id: if(query_log, do: query_log.id, else: nil),
        visitor_id: get_in(conn.assigns, [:analytics_identity, :visitor_id]),
        session_id: get_in(conn.assigns, [:analytics_identity, :session_id]),
        metadata: %{surface: "blog", query: normalized_query}
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
