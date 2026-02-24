defmodule AgentJido.Repo.Migrations.AddBlogTagAliases do
  use Ecto.Migration

  def up do
    create table(:blog_tag_aliases) do
      add :legacy_tag, :string, null: false
      add :canonical_tag, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:blog_tag_aliases, [:legacy_tag])
    create index(:blog_tag_aliases, [:canonical_tag])
  end

  def down do
    drop_if_exists index(:blog_tag_aliases, [:canonical_tag])
    drop_if_exists index(:blog_tag_aliases, [:legacy_tag])
    drop_if_exists table(:blog_tag_aliases)
  end
end
