defmodule AgentJido.Repo.Migrations.CreateArcanaTables do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS vector"

    create table(:arcana_collections, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:arcana_collections, [:name])

    create table(:arcana_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :content_type, :string, default: "text/plain"
      add :source_id, :string
      add :file_path, :string
      add :metadata, :map, default: %{}
      add :status, :string, default: "pending"
      add :error, :text
      add :chunk_count, :integer, default: 0
      add :collection_id, references(:arcana_collections, type: :binary_id, on_delete: :nilify_all)

      timestamps()
    end

    create table(:arcana_chunks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :text, null: false
      add :embedding, :vector, size: 384, null: false
      add :chunk_index, :integer, default: 0
      add :token_count, :integer
      add :metadata, :map, default: %{}
      add :document_id, references(:arcana_documents, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create index(:arcana_chunks, [:document_id])
    create index(:arcana_documents, [:source_id])
    create index(:arcana_documents, [:collection_id])

    execute """
    CREATE INDEX arcana_chunks_embedding_idx ON arcana_chunks
    USING hnsw (embedding vector_cosine_ops)
    """

    # Evaluation tables
    create table(:arcana_evaluation_test_cases, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :question, :text, null: false
      add :source, :string, null: false, default: "synthetic"
      add :source_chunk_id, references(:arcana_chunks, type: :uuid, on_delete: :nilify_all)

      timestamps()
    end

    create table(:arcana_evaluation_test_case_chunks, primary_key: false) do
      add :test_case_id, references(:arcana_evaluation_test_cases, type: :uuid, on_delete: :delete_all), null: false
      add :chunk_id, references(:arcana_chunks, type: :uuid, on_delete: :delete_all), null: false
    end

    create unique_index(:arcana_evaluation_test_case_chunks, [:test_case_id, :chunk_id])

    create table(:arcana_evaluation_runs, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :status, :string, null: false, default: "running"
      add :metrics, :map, default: %{}
      add :results, :map, default: %{}
      add :config, :map, default: %{}
      add :test_case_count, :integer, default: 0

      timestamps()
    end

    create index(:arcana_evaluation_runs, [:inserted_at])
  end

  def down do
    drop table(:arcana_evaluation_runs)
    drop table(:arcana_evaluation_test_case_chunks)
    drop table(:arcana_evaluation_test_cases)
    drop table(:arcana_chunks)
    drop table(:arcana_documents)
    drop table(:arcana_collections)
    # Note: We don't drop the vector extension as it may be used by other tables
  end
end
