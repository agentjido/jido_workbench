defmodule AgentJido.Blog do
  alias AgentJido.Blog.Post

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:agent_jido, "priv/blog/**/*.*md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_js, :makeup_html]

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  @posts_by_id Map.new(@posts, fn post -> {post.id, post} end)

  def all_posts, do: @posts
  def all_tags, do: @tags

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def get_post_by_id!(id) do
    Map.get(@posts_by_id, id) ||
      raise NotFoundError, "post with id=#{id} not found"
  end

  def get_posts_by_tag!(tag) do
    case Enum.filter(all_posts(), &(tag in &1.tags)) do
      [] -> raise NotFoundError, "posts with tag=#{tag} not found"
      posts -> posts
    end
  end
end
