defmodule AgentJido.Repo.Migrations.ImportLegacyBlogContent do
  use Ecto.Migration

  def up do
    stats = AgentJido.Blog.LegacyImporter.import!(transaction?: false)

    IO.puts(
      "Legacy blog import migration complete: created=#{stats.created} updated=#{stats.updated} aliases=#{stats.aliases} slug_aliases=#{stats.slug_aliases} tag_aliases=#{stats.tag_aliases}"
    )
  end

  def down do
    :ok
  end
end
