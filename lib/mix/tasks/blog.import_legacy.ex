defmodule Mix.Tasks.Blog.ImportLegacy do
  @moduledoc """
  Imports legacy markdown blog content (`priv/blog/**`) into PhoenixBlog tables.

  ## Examples

      mix blog.import_legacy --dry-run
      mix blog.import_legacy
  """
  use Mix.Task

  alias AgentJido.Blog.EditorBlocks
  alias AgentJido.Blog.Legacy
  alias AgentJido.Blog.SlugAlias
  alias AgentJido.Blog.Post, as: LegacyPost
  alias AgentJido.Repo

  @shortdoc "Imports legacy markdown posts into PhoenixBlog"

  @switches [dry_run: :boolean]

  @impl true
  def run(args) do
    {opts, _argv, _invalid} = OptionParser.parse(args, strict: @switches)
    dry_run? = Keyword.get(opts, :dry_run, false)

    Mix.Task.run("app.start")

    legacy_posts = Legacy.all_posts()
    canonical_map = build_canonical_map(legacy_posts)
    duplicate_canonicals = duplicate_canonicals(canonical_map)

    if duplicate_canonicals != [] do
      raise Mix.Error, "slug collisions detected: #{Enum.join(duplicate_canonicals, ", ")}"
    end

    plan = build_plan(legacy_posts, canonical_map)

    if dry_run? do
      print_dry_run(plan)
    else
      apply_plan(plan)
    end
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

  defp build_plan(legacy_posts, canonical_map) do
    Enum.map(legacy_posts, fn post ->
      canonical_slug = Map.fetch!(canonical_map, post.id)

      attrs = %{
        "title" => post.title,
        "slug" => canonical_slug,
        "body" =>
          EditorBlocks.html_to_editor_body(post.body,
            source_path: post.source_path,
            post_type: post.post_type,
            audience: post.audience,
            related_docs: post.related_docs || [],
            related_posts: post.related_posts || [],
            is_livebook: post.is_livebook
          ),
        "status" => "published",
        "tags" => Enum.map(post.tags || [], &to_string/1),
        "seo_description" => post.description,
        "author" => post.author,
        "published_at" => DateTime.new!(post.date, ~T[00:00:00], "Etc/UTC")
      }

      %{legacy_post: post, canonical_slug: canonical_slug, attrs: attrs}
    end)
  end

  defp print_dry_run(plan) do
    Mix.shell().info("Legacy posts discovered: #{length(plan)}")

    {redirects, canonical} =
      Enum.split_with(plan, fn row ->
        row.legacy_post.id != row.canonical_slug
      end)

    Mix.shell().info("Canonical slugs unchanged: #{length(canonical)}")
    Mix.shell().info("Legacy redirect aliases: #{length(redirects)}")

    if redirects != [] do
      Mix.shell().info("Redirect mappings:")

      Enum.each(redirects, fn row ->
        Mix.shell().info("  /blog/#{row.legacy_post.id} -> /blog/#{row.canonical_slug}")
      end)
    end
  end

  defp apply_plan(plan) do
    {created, updated, aliases} =
      Repo.transaction(fn ->
        Enum.reduce(plan, {0, 0, 0}, fn row, {created_acc, updated_acc, alias_acc} ->
          {created_next, updated_next} = upsert_post(row.attrs, created_acc, updated_acc)
          alias_next = maybe_upsert_alias(row.legacy_post.id, row.canonical_slug, alias_acc)
          {created_next, updated_next, alias_next}
        end)
      end)
      |> case do
        {:ok, stats} -> stats
        {:error, reason} -> raise Mix.Error, "import failed: #{inspect(reason)}"
      end

    Mix.shell().info("Legacy import complete")
    Mix.shell().info("  created: #{created}")
    Mix.shell().info("  updated: #{updated}")
    Mix.shell().info("  aliases: #{aliases}")
  end

  defp upsert_post(attrs, created_acc, updated_acc) do
    slug = Map.fetch!(attrs, "slug")

    case PhoenixBlog.get_post_by_slug_admin(slug) do
      nil ->
        case PhoenixBlog.create_post(attrs) do
          {:ok, _post} -> {created_acc + 1, updated_acc}
          {:error, changeset} -> Repo.rollback({:create_failed, slug, changeset})
        end

      existing ->
        case PhoenixBlog.update_post(existing, attrs) do
          {:ok, _post} -> {created_acc, updated_acc + 1}
          {:error, changeset} -> Repo.rollback({:update_failed, slug, changeset})
        end
    end
  end

  defp maybe_upsert_alias(legacy_slug, canonical_slug, alias_acc) do
    if legacy_slug == canonical_slug do
      alias_acc
    else
      case SlugAlias.upsert(legacy_slug, canonical_slug) do
        {:ok, _alias} -> alias_acc + 1
        {:error, changeset} -> Repo.rollback({:alias_failed, legacy_slug, changeset})
      end
    end
  end

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
