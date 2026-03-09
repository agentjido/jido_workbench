defmodule AgentJido.Repo.Migrations.RemovePhoenixBlogTables do
  use Ecto.Migration

  def up do
    drop_if_exists table(:phoenix_blog_post_likes)
    drop_if_exists table(:phoenix_blog_posts)
    drop_if_exists table(:blog_slug_aliases)
    drop_if_exists table(:blog_tag_aliases)
  end

  def down, do: :ok
end
