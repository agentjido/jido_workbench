defmodule AgentJidoWeb.BlogController do
  @moduledoc """
  HTTP endpoints for blog-adjacent responses that are not LiveView pages.
  """
  use AgentJidoWeb, :controller

  alias AgentJido.Blog

  def feed(conn, _params) do
    posts = Blog.all_posts()
    feed_xml = Phoenix.Template.render_to_string(AgentJidoWeb.BlogHTML, "feed", "xml", posts: posts)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, feed_xml)
  end
end
