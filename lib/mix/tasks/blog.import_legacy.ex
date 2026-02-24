defmodule Mix.Tasks.Blog.ImportLegacy do
  @moduledoc """
  Imports legacy markdown blog content (`priv/blog/**`) into PhoenixBlog tables.

  ## Examples

      mix blog.import_legacy --dry-run
      mix blog.import_legacy
  """
  use Mix.Task

  alias AgentJido.Blog.LegacyImporter

  @shortdoc "Imports legacy markdown posts into PhoenixBlog"

  @switches [dry_run: :boolean]

  @impl true
  def run(args) do
    {opts, _argv, _invalid} = OptionParser.parse(args, strict: @switches)
    dry_run? = Keyword.get(opts, :dry_run, false)

    Mix.Task.run("app.start")

    if dry_run? do
      print_dry_run(LegacyImporter.dry_run!())
    else
      print_stats(LegacyImporter.import!())
    end
  end

  defp print_dry_run(summary) do
    Mix.shell().info("Legacy posts discovered: #{summary.total_posts}")
    Mix.shell().info("Canonical slugs unchanged: #{summary.canonical_unchanged}")
    Mix.shell().info("Legacy redirect aliases: #{summary.alias_count}")

    if summary.redirects != [] do
      Mix.shell().info("Redirect mappings:")

      Enum.each(summary.redirects, fn redirect ->
        Mix.shell().info("  /blog/#{redirect.legacy_slug} -> /blog/#{redirect.canonical_slug}")
      end)
    end
  end

  defp print_stats(stats) do
    Mix.shell().info("Legacy import complete")
    Mix.shell().info("  created: #{stats.created}")
    Mix.shell().info("  updated: #{stats.updated}")
    Mix.shell().info("  aliases: #{stats.aliases}")
  end
end
