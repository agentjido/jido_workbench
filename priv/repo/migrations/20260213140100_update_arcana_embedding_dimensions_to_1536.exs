defmodule AgentJido.Repo.Migrations.UpdateArcanaEmbeddingDimensionsTo1536 do
  use Ecto.Migration

  @hnsw_index "arcana_chunks_embedding_idx"

  def up do
    drop_embedding_index()
    reset_chunks_for_reembed()

    alter table(:arcana_chunks) do
      modify(:embedding, :vector, size: 1536, null: false)
    end

    create_embedding_index()
  end

  def down do
    drop_embedding_index()
    reset_chunks_for_reembed()

    alter table(:arcana_chunks) do
      modify(:embedding, :vector, size: 384, null: false)
    end

    create_embedding_index()
  end

  defp reset_chunks_for_reembed do
    # Existing vectors cannot be resized reliably across dimensions.
    # Drop chunk rows and mark documents pending so they can be re-chunked/re-embedded.
    execute("DELETE FROM arcana_chunks")

    execute("""
    UPDATE arcana_documents
    SET chunk_count = 0,
        status = 'pending',
        updated_at = NOW()
    WHERE chunk_count <> 0 OR status <> 'pending'
    """)
  end

  defp drop_embedding_index do
    execute("DROP INDEX IF EXISTS #{@hnsw_index}")
  end

  defp create_embedding_index do
    execute("""
    CREATE INDEX #{@hnsw_index} ON arcana_chunks
    USING hnsw (embedding vector_cosine_ops)
    """)
  end
end
