defmodule AgentJido.BlogTest do
  use AgentJido.DataCase, async: false

  alias AgentJido.Blog
  alias AgentJido.Blog.SlugAlias
  alias PhoenixBlog.Post, as: BlogPost

  setup do
    Repo.delete_all(SlugAlias)
    Repo.delete_all(BlogPost)
    :ok
  end

  test "get_published_post_by_slug!/1 returns a published post from the database" do
    insert_post!(%{slug: "direct-post", title: "Direct Post", status: :published})

    post = Blog.get_published_post_by_slug!("direct-post")

    assert post.id == "direct-post"
    assert post.title == "Direct Post"
  end

  test "get_published_post_by_slug!/1 resolves legacy aliases to the canonical post" do
    insert_post!(%{slug: "canonical-post", title: "Canonical Post", status: :published})
    {:ok, _alias} = SlugAlias.upsert("legacy-post", "canonical-post")

    post = Blog.get_published_post_by_slug!("legacy-post")

    assert post.id == "canonical-post"
    assert post.title == "Canonical Post"
  end

  test "get_published_post_by_slug!/1 raises for missing or unpublished posts" do
    insert_post!(%{slug: "draft-post", title: "Draft Post", status: :draft, published_at: nil})

    assert_raise Blog.NotFoundError, fn ->
      Blog.get_published_post_by_slug!("draft-post")
    end

    assert_raise Blog.NotFoundError, fn ->
      Blog.get_published_post_by_slug!("missing-post")
    end
  end

  defp insert_post!(attrs) do
    defaults = %{
      title: "Post",
      slug: "post",
      body: %{
        "blocks" => [
          %{
            "type" => "paragraph",
            "data" => %{"text" => "Jido blog post body"}
          }
        ]
      },
      status: :published,
      tags: ["agents"],
      seo_description: "A post",
      author: "AgentJido Team",
      published_at: DateTime.utc_now() |> DateTime.add(-60, :second) |> DateTime.truncate(:second)
    }

    attrs =
      defaults
      |> Map.merge(attrs)
      |> maybe_drop_published_at()

    %BlogPost{}
    |> BlogPost.changeset(attrs)
    |> Repo.insert!()
  end

  defp maybe_drop_published_at(%{published_at: nil} = attrs), do: Map.delete(attrs, :published_at)
  defp maybe_drop_published_at(attrs), do: attrs
end
