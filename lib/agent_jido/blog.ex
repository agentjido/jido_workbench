defmodule AgentJido.Blog do
  @moduledoc """
  Blog facade used across the site.

  Blog content is compiled from Markdown and LiveMarkdown files in `priv/blog/`
  using NimblePublisher.
  """

  alias AgentJido.Blog.Legacy
  alias AgentJido.Blog.Post
  alias AgentJido.Blog.SlugAlias
  alias AgentJido.Blog.TagAlias
  alias AgentJido.Blog.Taxonomy

  @default_author "AgentJido Team"
  @default_post_type :post
  @default_audience :general

  @type post_source :: :static

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  @spec all_posts() :: [Post.t()]
  def all_posts do
    Enum.map(Legacy.all_posts(), &normalize_legacy_post/1)
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

    fetch_post(normalized_id) ||
      raise NotFoundError, "post with id=#{id} not found"
  end

  def get_post_by_id!(id), do: raise(NotFoundError, "post with id=#{inspect(id)} not found")

  @spec get_published_post_by_slug!(String.t()) :: Post.t()
  def get_published_post_by_slug!(slug) when is_binary(slug) do
    normalized_slug = String.trim(slug)
    get_post_by_id!(resolve_canonical_slug(normalized_slug) || normalized_slug)
  end

  def get_published_post_by_slug!(slug),
    do: raise(NotFoundError, "post with slug=#{inspect(slug)} not found")

  @spec get_posts_by_tag!(String.t()) :: [Post.t()]
  def get_posts_by_tag!(tag) when is_binary(tag) do
    normalized_tag = String.trim(tag)
    canonical_tag = TagAlias.canonical_tag_for(normalized_tag) || Taxonomy.canonical_tag(normalized_tag)

    case Enum.filter(all_posts(), &(canonical_tag in (&1.tags || []))) do
      [] -> raise NotFoundError, "posts with tag=#{tag} not found"
      posts -> posts
    end
  end

  def get_posts_by_tag!(tag), do: raise(NotFoundError, "posts with tag=#{inspect(tag)} not found")

  @spec source() :: post_source()
  def source, do: :static

  defp fetch_post(id) do
    posts = all_posts()

    Enum.find(posts, &(&1.id == id)) ||
      find_by_alias(posts, id)
  end

  defp find_by_alias(posts, legacy_slug) do
    case resolve_canonical_slug(legacy_slug) do
      canonical when is_binary(canonical) ->
        Enum.find(posts, &(&1.id == canonical))

      _ ->
        nil
    end
  end

  defp resolve_canonical_slug(slug) when is_binary(slug) do
    case SlugAlias.canonical_slug_for(slug) do
      canonical when is_binary(canonical) and canonical != "" and canonical != slug -> canonical
      _ -> nil
    end
  end

  defp normalize_legacy_post(%Post{} = post) do
    metadata =
      Taxonomy.metadata(
        Map.get(post, :post_type, @default_post_type),
        Map.get(post, :audience, @default_audience),
        Map.get(post, :tags, []),
        %{
          journey_stage: Map.get(post, :journey_stage),
          content_intent: Map.get(post, :content_intent),
          capability_theme: Map.get(post, :capability_theme),
          evidence_surface: Map.get(post, :evidence_surface)
        }
      )

    seo =
      case Map.get(post, :seo, %{}) do
        value when is_map(value) -> value
        _ -> %{}
      end
      |> Map.put(:keywords, metadata.tags)

    %Post{
      post
      | author: normalize_string(Map.get(post, :author)) || @default_author,
        description: normalize_string(Map.get(post, :description)) || "",
        tags: metadata.tags,
        post_type: metadata.post_type,
        audience: metadata.audience,
        journey_stage: metadata.journey_stage,
        content_intent: metadata.content_intent,
        capability_theme: metadata.capability_theme,
        evidence_surface: metadata.evidence_surface,
        seo: seo
    }
  end

  defp normalize_string(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_string(value) when is_atom(value), do: value |> Atom.to_string() |> normalize_string()
  defp normalize_string(_value), do: nil
end
