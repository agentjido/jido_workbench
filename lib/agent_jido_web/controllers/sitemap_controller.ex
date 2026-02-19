defmodule AgentJidoWeb.SitemapController do
  use AgentJidoWeb, :controller

  alias AgentJido.Blog
  alias AgentJido.Ecosystem
  alias AgentJido.Pages

  def index(conn, _params) do
    pages =
      Pages.all_pages()
      |> Enum.reject(&(&1.category == :training))

    conn
    |> put_resp_content_type("application/xml")
    |> render(:index,
      blog_posts: Blog.all_posts(),
      pages: pages,
      ecosystem_packages: Ecosystem.public_packages()
    )
  end
end
