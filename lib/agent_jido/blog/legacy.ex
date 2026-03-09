defmodule AgentJido.Blog.Legacy do
  @moduledoc """
  Compile-time NimblePublisher loader for static blog content.
  """
  alias AgentJido.Blog.Post

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:agent_jido, "priv/blog/**/*.*md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_js, :makeup_html]

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()
  @posts_by_id Map.new(@posts, fn post -> {post.id, post} end)
  @slug_aliases Enum.reduce(@posts, %{}, fn post, acc ->
                  legacy_slug =
                    post.source_path
                    |> Path.rootname()
                    |> Path.basename()
                    |> String.split("-", parts: 3)
                    |> case do
                      [_month, _day, slug] -> slug
                      _ -> nil
                    end

                  if is_binary(legacy_slug) and legacy_slug != "" and legacy_slug != post.id do
                    Map.put(acc, legacy_slug, post.id)
                  else
                    acc
                  end
                end)

  @spec all_posts() :: [Post.t()]
  def all_posts, do: @posts

  @spec all_tags() :: [String.t()]
  def all_tags, do: @tags

  @spec canonical_slug_for(String.t()) :: String.t() | nil
  def canonical_slug_for(slug) when is_binary(slug) do
    normalized = String.trim(slug)

    case Map.get(@slug_aliases, normalized) do
      canonical when is_binary(canonical) and canonical != normalized -> canonical
      _ -> nil
    end
  end

  def canonical_slug_for(_slug), do: nil

  @spec get_post_by_id!(String.t()) :: Post.t()
  def get_post_by_id!(id) do
    normalized_id = id |> to_string() |> String.trim()
    canonical_id = canonical_slug_for(normalized_id) || normalized_id

    Map.get(@posts_by_id, canonical_id) ||
      raise AgentJido.Blog.NotFoundError, "post with id=#{id} not found"
  end
end
