defmodule AgentJidoWeb.BlogLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Blog

  describe "blog live navigation" do
    test "blog routes mount as LiveView and patch between index and show", %{conn: conn} do
      post = Blog.all_posts() |> hd()
      post_path = ~p"/blog/#{post.id}"

      {:ok, view, html} = live(conn, ~p"/blog")
      assert html =~ "Engineering Blog"
      assert html =~ ~s(href="/features")
      assert html =~ ~s(href="/ecosystem")
      assert html =~ ~s(href="/examples")
      assert html =~ ~s(href="/docs")
      assert html =~ ~s(href="/blog")
      refute html =~ "Powered by DuckDuckGo"

      view
      |> element(~s(a[href="#{post_path}"]), "Read More")
      |> render_click()

      assert_patch(view, post_path)
      rendered_show = render(view)
      assert rendered_show =~ post.title
      assert rendered_show =~ "markdown.new"
      assert rendered_show =~ "Open page in markdown.new" or rendered_show =~ "Open source in markdown.new"

      view
      |> element(~s(a[href="/blog"]), "Back to all posts")
      |> render_click()

      assert_patch(view, ~p"/blog")
      assert render(view) =~ "Engineering Blog"
    end

    test "blog tag page mounts as LiveView", %{conn: conn} do
      tag = Blog.all_tags() |> hd()
      tag_path = ~p"/blog/tags/#{tag}"

      {:ok, _view, html} = live(conn, tag_path)

      assert html =~ "Posts tagged with"
      assert html =~ tag
      refute html =~ "Searches via DuckDuckGo"
    end
  end
end
