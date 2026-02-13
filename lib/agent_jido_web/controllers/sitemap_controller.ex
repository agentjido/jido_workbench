defmodule AgentJidoWeb.SitemapController do
  use AgentJidoWeb, :controller

  alias AgentJido.Blog
  alias AgentJido.Ecosystem
  alias AgentJido.Pages

  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/xml")
    |> render(:index,
      blog_posts: Blog.all_posts(),
      pages: Pages.all_pages(),
      ecosystem_packages: Ecosystem.public_packages()
    )
  end
end
