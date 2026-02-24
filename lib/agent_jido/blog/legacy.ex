defmodule AgentJido.Blog.Legacy do
  @moduledoc """
  Compile-time NimblePublisher loader used for legacy markdown import.
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

  @spec all_posts() :: [Post.t()]
  def all_posts, do: @posts

  @spec all_tags() :: [String.t()]
  def all_tags, do: @tags

  @spec get_post_by_id!(String.t()) :: Post.t()
  def get_post_by_id!(id) do
    Map.get(@posts_by_id, id) ||
      raise AgentJido.Blog.NotFoundError, "post with id=#{id} not found"
  end
end
