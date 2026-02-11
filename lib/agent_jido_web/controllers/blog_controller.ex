defmodule AgentJidoWeb.BlogController do
  use AgentJidoWeb, :controller

  alias AgentJido.Blog

  def index(conn, _params) do
    render(conn, :index,
      posts: Blog.all_posts(),
      tags: Blog.all_tags(),
      og_image: "https://agentjido.xyz/og/blog.png"
    )
  end

  def show(conn, %{"slug" => slug}) do
    post = Blog.get_post_by_id!(slug)

    render(conn, :show,
      post: post,
      og_image: "https://agentjido.xyz/og/blog/#{slug}"
    )
  end

  def tag(conn, %{"tag" => tag}) do
    posts = Blog.get_posts_by_tag!(tag)

    render(conn, :tag,
      posts: posts,
      tag: tag,
      tags: Blog.all_tags(),
      og_image: "https://agentjido.xyz/og/blog.png"
    )
  end

  def search(conn, %{"q" => query}) do
    site_url = AgentJidoWeb.Endpoint.url()
    # Extract hostname from the URL without the protocol
    hostname = URI.parse(site_url).host || "jido.app"
    search_url = "https://duckduckgo.com/?q=#{URI.encode_www_form(query)}+site:#{hostname}"

    conn
    |> redirect(external: search_url)
  end

  def search(conn, _params) do
    redirect(conn, to: ~p"/blog")
  end

  def feed(conn, _params) do
    posts = Blog.all_posts()

    conn
    |> put_resp_content_type("application/xml")
    |> render(:feed, posts: posts)
  end
end
