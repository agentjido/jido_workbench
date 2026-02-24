defmodule AgentJido.Blog.LegacyImporter do
  @moduledoc """
  Imports legacy markdown blog content into PhoenixBlog tables.

  This module is runtime-safe and can be called from release migrations.
  """

  alias AgentJido.Blog.EditorBlocks
  alias AgentJido.Blog.Legacy
  alias AgentJido.Blog.Post, as: LegacyPost
  alias AgentJido.Blog.SlugAlias
  alias AgentJido.Blog.TagAlias
  alias AgentJido.Blog.Taxonomy
  alias AgentJido.Repo

  @type redirect_mapping :: %{legacy_slug: String.t(), canonical_slug: String.t()}
  @type tag_redirect_mapping :: %{legacy_tag: String.t(), canonical_tag: String.t()}

  @type dry_run_summary :: %{
          total_posts: non_neg_integer(),
          canonical_unchanged: non_neg_integer(),
          alias_count: non_neg_integer(),
          redirects: [redirect_mapping()],
          tag_alias_count: non_neg_integer(),
          tag_redirects: [tag_redirect_mapping()]
        }

  @type import_stats :: %{
          created: non_neg_integer(),
          updated: non_neg_integer(),
          aliases: non_neg_integer(),
          slug_aliases: non_neg_integer(),
          tag_aliases: non_neg_integer()
        }

  @spec dry_run!() :: dry_run_summary()
  def dry_run! do
    plan = build_plan!()

    redirects =
      plan
      |> Enum.filter(&(&1.legacy_post.id != &1.canonical_slug))
      |> Enum.map(fn row ->
        %{legacy_slug: row.legacy_post.id, canonical_slug: row.canonical_slug}
      end)

    tag_redirects =
      plan
      |> Enum.flat_map(& &1.tag_aliases)
      |> Kernel.++(Taxonomy.default_tag_alias_rows())
      |> Enum.uniq_by(& &1.legacy_tag)
      |> Enum.sort_by(& &1.legacy_tag)

    %{
      total_posts: length(plan),
      canonical_unchanged: length(plan) - length(redirects),
      alias_count: length(redirects),
      redirects: redirects,
      tag_alias_count: length(tag_redirects),
      tag_redirects: tag_redirects
    }
  end

  @spec import!(keyword()) :: import_stats()
  def import!(opts \\ []) do
    plan = build_plan!()
    transaction? = Keyword.get(opts, :transaction?, true)

    {created, updated, slug_aliases, tag_aliases} =
      if transaction? do
        Repo.transaction(fn -> apply_plan(plan, true) end)
        |> case do
          {:ok, stats} -> stats
          {:error, reason} -> raise "legacy blog import failed: #{inspect(reason)}"
        end
      else
        apply_plan(plan, false)
      end

    %{
      created: created,
      updated: updated,
      aliases: slug_aliases + tag_aliases,
      slug_aliases: slug_aliases,
      tag_aliases: tag_aliases
    }
  end

  defp build_plan! do
    legacy_posts = Legacy.all_posts()
    canonical_map = build_canonical_map(legacy_posts)
    duplicate_canonicals = duplicate_canonicals(canonical_map)

    if duplicate_canonicals != [] do
      raise "legacy blog import slug collisions: #{Enum.join(duplicate_canonicals, ", ")}"
    end

    Enum.map(legacy_posts, fn post ->
      canonical_slug = Map.fetch!(canonical_map, post.id)

      metadata =
        Taxonomy.metadata(post.post_type, post.audience, post.tags || [],
          journey_stage: Map.get(post, :journey_stage),
          content_intent: Map.get(post, :content_intent),
          capability_theme: Map.get(post, :capability_theme),
          evidence_surface: Map.get(post, :evidence_surface)
        )

      attrs = %{
        "title" => post.title,
        "slug" => canonical_slug,
        "body" =>
          EditorBlocks.html_to_editor_body(post.body,
            source_path: post.source_path,
            post_type: metadata.post_type,
            audience: metadata.audience,
            journey_stage: metadata.journey_stage,
            content_intent: metadata.content_intent,
            capability_theme: metadata.capability_theme,
            evidence_surface: metadata.evidence_surface,
            related_docs: post.related_docs || [],
            related_posts: post.related_posts || [],
            is_livebook: post.is_livebook
          ),
        "status" => "published",
        "tags" => metadata.tags,
        "seo_description" => post.description,
        "author" => post.author,
        "published_at" => DateTime.new!(post.date, ~T[00:00:00], "Etc/UTC")
      }

      %{
        legacy_post: post,
        canonical_slug: canonical_slug,
        attrs: attrs,
        tag_aliases: Taxonomy.tag_aliases_for(post.tags || [])
      }
    end)
  end

  defp build_canonical_map(legacy_posts) do
    Map.new(legacy_posts, fn %LegacyPost{id: legacy_slug} ->
      {legacy_slug, canonical_slug(legacy_slug)}
    end)
  end

  defp duplicate_canonicals(canonical_map) do
    canonical_map
    |> Enum.group_by(fn {_legacy, canonical} -> canonical end)
    |> Enum.filter(fn {_canonical, pairs} -> length(pairs) > 1 end)
    |> Enum.map(fn {canonical, _pairs} -> canonical end)
    |> Enum.sort()
  end

  defp apply_plan(plan, rollback?) do
    tag_aliases =
      plan
      |> Enum.flat_map(& &1.tag_aliases)
      |> Kernel.++(Taxonomy.default_tag_alias_rows())
      |> Enum.uniq_by(& &1.legacy_tag)

    tag_alias_count = upsert_tag_aliases(tag_aliases, rollback?)

    {created, updated, slug_aliases} =
      Enum.reduce(plan, {0, 0, 0}, fn row, {created_acc, updated_acc, alias_acc} ->
        {created_next, updated_next} = upsert_post(row.attrs, created_acc, updated_acc, rollback?)
        alias_next = maybe_upsert_slug_alias(row.legacy_post.id, row.canonical_slug, alias_acc, rollback?)
        {created_next, updated_next, alias_next}
      end)

    {created, updated, slug_aliases, tag_alias_count}
  end

  defp upsert_post(attrs, created_acc, updated_acc, rollback?) do
    slug = Map.fetch!(attrs, "slug")

    case PhoenixBlog.get_post_by_slug_admin(slug) do
      nil ->
        case PhoenixBlog.create_post(attrs) do
          {:ok, _post} -> {created_acc + 1, updated_acc}
          {:error, changeset} -> fail!({:create_failed, slug, changeset}, rollback?)
        end

      existing ->
        case PhoenixBlog.update_post(existing, attrs) do
          {:ok, _post} -> {created_acc, updated_acc + 1}
          {:error, changeset} -> fail!({:update_failed, slug, changeset}, rollback?)
        end
    end
  end

  defp maybe_upsert_slug_alias(legacy_slug, canonical_slug, alias_acc, rollback?) do
    if legacy_slug == canonical_slug do
      alias_acc
    else
      case SlugAlias.upsert(legacy_slug, canonical_slug) do
        {:ok, _alias} -> alias_acc + 1
        {:error, changeset} -> fail!({:alias_failed, legacy_slug, changeset}, rollback?)
      end
    end
  end

  defp upsert_tag_aliases(tag_aliases, rollback?) do
    Enum.reduce(tag_aliases, 0, fn %{legacy_tag: legacy_tag, canonical_tag: canonical_tag}, acc ->
      case TagAlias.upsert(legacy_tag, canonical_tag) do
        {:ok, _alias} -> acc + 1
        {:error, changeset} -> fail!({:tag_alias_failed, legacy_tag, changeset}, rollback?)
      end
    end)
  end

  defp fail!(reason, true), do: Repo.rollback(reason)
  defp fail!(reason, false), do: raise("legacy blog import failed: #{inspect(reason)}")

  defp canonical_slug(slug) do
    slug
    |> to_string()
    |> String.downcase()
    |> String.replace("_", "-")
    |> String.replace(~r/[^a-z0-9-]/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end
end
