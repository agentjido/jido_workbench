defmodule AgentJido.Repo.Migrations.CreateArcanaGraphTables do
  use Ecto.Migration

  def up do
    create table(:arcana_graph_entities, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)
      add(:type, :string, null: false)
      add(:description, :text)
      add(:embedding, :vector, size: 1536)
      add(:metadata, :map, default: %{})
      add(:chunk_id, references(:arcana_chunks, type: :binary_id, on_delete: :nilify_all))
      add(:collection_id, references(:arcana_collections, type: :binary_id, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:arcana_graph_entities, [:name, :collection_id]))
    create(index(:arcana_graph_entities, [:collection_id]))
    create(index(:arcana_graph_entities, [:type]))

    # HNSW index for entity embedding similarity search
    execute("""
    CREATE INDEX arcana_graph_entities_embedding_idx ON arcana_graph_entities
    USING hnsw (embedding vector_cosine_ops)
    WHERE embedding IS NOT NULL
    """)

    create table(:arcana_graph_entity_mentions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:span_start, :integer)
      add(:span_end, :integer)
      add(:context, :text)
      add(:entity_id, references(:arcana_graph_entities, type: :binary_id, on_delete: :delete_all), null: false)
      add(:chunk_id, references(:arcana_chunks, type: :binary_id, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:arcana_graph_entity_mentions, [:entity_id]))
    create(index(:arcana_graph_entity_mentions, [:chunk_id]))

    create table(:arcana_graph_relationships, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :string, null: false)
      add(:description, :text)
      add(:strength, :integer)
      add(:metadata, :map, default: %{})
      add(:source_id, references(:arcana_graph_entities, type: :binary_id, on_delete: :delete_all), null: false)
      add(:target_id, references(:arcana_graph_entities, type: :binary_id, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:arcana_graph_relationships, [:source_id]))
    create(index(:arcana_graph_relationships, [:target_id]))
    create(index(:arcana_graph_relationships, [:type]))

    create table(:arcana_graph_communities, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:level, :integer, null: false)
      add(:description, :text)
      add(:summary, :text)
      add(:entity_ids, {:array, :binary_id}, default: [])
      add(:dirty, :boolean, default: true)
      add(:change_count, :integer, default: 0)
      add(:collection_id, references(:arcana_collections, type: :binary_id, on_delete: :delete_all))

      timestamps()
    end

    create(index(:arcana_graph_communities, [:collection_id]))
    create(index(:arcana_graph_communities, [:level]))
  end

  def down do
    drop(table(:arcana_graph_communities))
    drop(table(:arcana_graph_relationships))
    drop(table(:arcana_graph_entity_mentions))
    drop(table(:arcana_graph_entities))
  end
end
