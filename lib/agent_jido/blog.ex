defmodule AgentJido.Blog do
  @moduledoc """
  Blog facade used across the site.

  Primary source is `phoenix_blog` DB content. If the DB has no published posts yet,
  it falls back to legacy markdown content so existing pages/tests continue to work
  until import is executed.
  """
  import Ecto.Query

  alias AgentJido.Blog.EditorBlocks
  alias AgentJido.Blog.Legacy
  alias AgentJido.Blog.Post
  alias AgentJido.Blog.SlugAlias
  alias AgentJido.Repo
  alias PhoenixBlog.Post, as: BlogPost

  @default_author "AgentJido Team"
  @default_post_type :post
  @default_audience :general

  @type post_source :: :database | :legacy

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  @spec all_posts() :: [Post.t()]
  def all_posts do
    case published_posts_from_db() do
      [] -> Legacy.all_posts()
      posts -> posts
    end
  end

  @spec all_tags() :: [String.t()]
  def all_tags do
    all_posts()
    |> Enum.flat_map(&(&1.tags || []))
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec get_post_by_id!(String.t()) :: Post.t()
  def get_post_by_id!(id) when is_binary(id) do
    normalized_id = String.trim(id)
    posts = all_posts()

    Enum.find(posts, &(&1.id == normalized_id)) ||
      find_by_legacy_alias(posts, normalized_id) ||
      raise NotFoundError, "post with id=#{id} not found"
  end

  def get_post_by_id!(id), do: raise(NotFoundError, "post with id=#{inspect(id)} not found")

  @spec get_posts_by_tag!(String.t()) :: [Post.t()]
  def get_posts_by_tag!(tag) when is_binary(tag) do
    normalized_tag = String.trim(tag)

    case Enum.filter(all_posts(), &(normalized_tag in (&1.tags || []))) do
      [] -> raise NotFoundError, "posts with tag=#{tag} not found"
      posts -> posts
    end
  end

  def get_posts_by_tag!(tag), do: raise(NotFoundError, "posts with tag=#{inspect(tag)} not found")

  @spec source() :: post_source()
  def source do
    if has_published_posts?(), do: :database, else: :legacy
  end

  @spec has_published_posts?() :: boolean()
  def has_published_posts? do
    Repo.exists?(published_posts_query())
  rescue
    _ -> false
  end

  defp find_by_legacy_alias(posts, legacy_slug) do
    case SlugAlias.canonical_slug_for(legacy_slug) do
      canonical when is_binary(canonical) ->
        Enum.find(posts, &(&1.id == canonical))

      _ ->
        nil
    end
  end

  defp published_posts_from_db do
    published_posts_query()
    |> Repo.all()
    |> Enum.map(&to_compat_post/1)
  rescue
    _ -> []
  end

  defp published_posts_query do
    now = DateTime.utc_now(:second)

    from post in BlogPost,
      where: post.status == :published and is_nil(post.deleted_at) and post.published_at <= ^now,
      order_by: [desc: post.published_at, desc: post.inserted_at]
  end

  defp to_compat_post(%BlogPost{} = post) do
    body_map = normalize_body(post.body)
    body_html = EditorBlocks.body_to_html(body_map)
    body_text = EditorBlocks.body_to_text(body_map)
    description = normalize_string(post.seo_description) || summarize(body_text)
    date = published_date(post)
    word_count = body_text |> tokenize() |> length()

    struct(Post,
      id: post.slug,
      author: normalize_string(post.author) || @default_author,
      title: normalize_string(post.title) || post.slug,
      body: body_html,
      description: description || "",
      tags: normalize_tags(post.tags),
      date: date,
      path: source_path(body_map),
      source_path: source_path(body_map),
      is_livebook: map_bool(body_map, "legacy_is_livebook", false),
      post_type: map_enum(body_map, "legacy_post_type", [:post, :announcement, :release, :tutorial, :case_study], @default_post_type),
      audience: map_enum(body_map, "legacy_audience", [:general, :beginner, :intermediate, :advanced], @default_audience),
      word_count: word_count,
      reading_time_minutes: max(1, div(word_count, 200)),
      related_docs: map_list(body_map, "legacy_related_docs"),
      related_posts: map_list(body_map, "legacy_related_posts"),
      validation: %{},
      freshness: %{content_hash: content_hash(post)},
      seo: %{
        og_description: description,
        og_image: normalize_string(post.featured_image_url),
        keywords: normalize_tags(post.tags),
        noindex: false
      },
      quality: %{},
      livebook: %{}
    )
  end

  defp source_path(body_map) do
    map_string(body_map, "legacy_source_path") || "phoenix_blog://posts"
  end

  defp published_date(%BlogPost{published_at: %DateTime{} = published_at}) do
    DateTime.to_date(published_at)
  end

  defp published_date(%BlogPost{inserted_at: %DateTime{} = inserted_at}) do
    DateTime.to_date(inserted_at)
  end

  defp published_date(_post), do: Date.utc_today()

  defp content_hash(post) do
    payload = :erlang.term_to_binary([post.slug, post.updated_at, post.body])
    :crypto.hash(:sha256, payload) |> Base.encode16(case: :lower)
  end

  defp normalize_body(body) when is_map(body), do: body
  defp normalize_body(_body), do: %{"blocks" => []}

  defp normalize_tags(tags) when is_list(tags) do
    tags
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  defp normalize_tags(_tags), do: []

  defp map_list(body_map, key) do
    case Map.get(body_map, key) do
      list when is_list(list) -> list
      _ -> []
    end
  end

  defp map_bool(body_map, key, default) do
    case Map.get(body_map, key) do
      value when is_boolean(value) -> value
      _ -> default
    end
  end

  defp map_enum(body_map, key, allowed, default) do
    raw = Map.get(body_map, key)

    case normalize_string(raw) do
      nil ->
        default

      value ->
        Enum.find(allowed, default, &(Atom.to_string(&1) == value))
    end
  end

  defp map_string(body_map, key) do
    body_map
    |> Map.get(key)
    |> normalize_string()
  end

  defp summarize(text) when is_binary(text) do
    trimmed = String.trim(text)

    case trimmed do
      "" ->
        nil

      _ ->
        if String.length(trimmed) > 180 do
          String.slice(trimmed, 0, 177) <> "..."
        else
          trimmed
        end
    end
  end

  defp summarize(_), do: nil

  defp tokenize(text) when is_binary(text) do
    String.split(text, ~r/\s+/, trim: true)
  end

  defp tokenize(_), do: []

  defp normalize_string(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_string(value) when is_atom(value), do: value |> Atom.to_string() |> normalize_string()
  defp normalize_string(_value), do: nil
end
