defmodule AgentJido.Repo.Migrations.AddPhoenixBlogAndSlugAliases do
  use Ecto.Migration

  def up do
    PhoenixBlog.Migration.up()

    create table(:blog_slug_aliases) do
      add :legacy_slug, :string, null: false
      add :canonical_slug, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:blog_slug_aliases, [:legacy_slug])
    create index(:blog_slug_aliases, [:canonical_slug])
  end

  def down do
    drop_if_exists index(:blog_slug_aliases, [:canonical_slug])
    drop_if_exists index(:blog_slug_aliases, [:legacy_slug])
    drop_if_exists table(:blog_slug_aliases)

    PhoenixBlog.Migration.down()
  end
end
