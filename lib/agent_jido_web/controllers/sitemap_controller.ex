defmodule AgentJidoWeb.SitemapController do
  use AgentJidoWeb, :controller

  alias AgentJido.Blog
  alias AgentJido.Documentation

  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/xml")
    |> render(:index,
      blog_posts: Blog.all_posts(),
      documents: Documentation.all_documents()
    )
  end
end
