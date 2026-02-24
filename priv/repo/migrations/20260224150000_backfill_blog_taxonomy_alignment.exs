defmodule AgentJido.Repo.Migrations.BackfillBlogTaxonomyAlignment do
  use Ecto.Migration

  def up do
    stats = AgentJido.Blog.LegacyImporter.import!(transaction?: false)

    IO.puts(
      "Blog taxonomy backfill complete: created=#{stats.created} updated=#{stats.updated} slug_aliases=#{stats.slug_aliases} tag_aliases=#{stats.tag_aliases}"
    )
  end

  def down do
    :ok
  end
end
