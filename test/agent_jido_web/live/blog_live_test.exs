defmodule AgentJidoWeb.BlogLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Blog

  describe "blog live navigation" do
    test "blog routes mount as LiveView and patch between index and show", %{conn: conn} do
      post = Blog.all_posts() |> hd()
      post_path = ~p"/blog/#{post.id}"

      {:ok, view, html} = live(conn, ~p"/blog")
      assert html =~ "Listing all posts"
      refute html =~ "Powered by DuckDuckGo"

      view
      |> element(~s(a[href="#{post_path}"]), "Read More")
      |> render_click()

      assert_patch(view, post_path)
      assert render(view) =~ post.title

      view
      |> element(~s(a[href="/blog"]), "Back to all posts")
      |> render_click()

      assert_patch(view, ~p"/blog")
      assert render(view) =~ "Listing all posts"
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
