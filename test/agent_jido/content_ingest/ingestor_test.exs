defmodule AgentJido.ContentIngest.IngestorTest do
  use AgentJido.DataCase, async: false

  alias AgentJido.ContentIngest.Ingestor
  alias AgentJido.ContentIngest.Inventory
  alias AgentJido.ContentIngest.Source
  alias Arcana.Document

  describe "sync/1" do
    test "is idempotent and handles update/delete lifecycle" do
      alpha_v1 = source("docs:/alpha", "test_docs", "Alpha value")
      beta_v1 = source("docs:/beta", "test_docs", "Beta value")

      result1 = Ingestor.sync(repo: Repo, sources: [alpha_v1, beta_v1])
      assert result1.inserted == 2
      assert result1.updated == 0
      assert result1.skipped == 0
      assert result1.deleted == 0
      assert result1.failed_count == 0
      assert managed_doc_count("test_docs") == 2

      result2 = Ingestor.sync(repo: Repo, sources: [alpha_v1, beta_v1])
      assert result2.inserted == 0
      assert result2.updated == 0
      assert result2.skipped == 2
      assert result2.deleted == 0
      assert result2.failed_count == 0
      assert managed_doc_count("test_docs") == 2

      alpha_v2 = source("docs:/alpha", "test_docs", "Alpha value updated")
      result3 = Ingestor.sync(repo: Repo, sources: [alpha_v2, beta_v1])
      assert result3.inserted == 0
      assert result3.updated == 1
      assert result3.skipped == 1
      assert result3.failed_count == 0
      assert managed_doc_count("test_docs") == 2
      assert managed_hash_for("docs:/alpha") == hash_for("Alpha value updated")

      result4 = Ingestor.sync(repo: Repo, sources: [alpha_v2])
      assert result4.inserted == 0
      assert result4.updated == 0
      assert result4.skipped == 1
      assert result4.deleted == 1
      assert result4.failed_count == 0
      assert managed_doc_count("test_docs") == 1
    end

    test "dry run reports changes without mutating database" do
      source_v1 = source("docs:/gamma", "test_docs_dry", "Gamma value")
      source_v2 = source("docs:/gamma", "test_docs_dry", "Gamma value changed")

      dry_insert = Ingestor.sync(repo: Repo, sources: [source_v1], dry_run: true)
      assert dry_insert.mode == :dry_run
      assert dry_insert.inserted == 1
      assert managed_doc_count("test_docs_dry") == 0

      apply_insert = Ingestor.sync(repo: Repo, sources: [source_v1], dry_run: false)
      assert apply_insert.inserted == 1
      assert managed_doc_count("test_docs_dry") == 1
      assert managed_hash_for("docs:/gamma") == hash_for("Gamma value")

      dry_update = Ingestor.sync(repo: Repo, sources: [source_v2], dry_run: true)
      assert dry_update.updated == 1
      assert managed_doc_count("test_docs_dry") == 1
      assert managed_hash_for("docs:/gamma") == hash_for("Gamma value")

      dry_delete =
        Ingestor.sync(
          repo: Repo,
          sources: [],
          dry_run: true,
          managed_collections: ["test_docs_dry"]
        )

      assert dry_delete.deleted == 1
      assert managed_doc_count("test_docs_dry") == 1
    end

    test "ingested content is searchable with fulltext mode" do
      alpha = source("docs:/search-alpha", "test_docs_search", "alpha search token")
      beta = source("docs:/search-beta", "test_docs_search", "beta search token")

      result = Ingestor.sync(repo: Repo, sources: [alpha, beta])
      assert result.inserted == 2

      assert {:ok, rows} =
               Arcana.search("alpha",
                 repo: Repo,
                 collection: "test_docs_search",
                 mode: :fulltext,
                 limit: 5
               )

      assert Enum.any?(rows, fn row ->
               String.contains?(String.downcase(row.text), "alpha")
             end)
    end
  end

  defp source(source_id, collection, text) do
    %Source{
      source_id: source_id,
      collection: collection,
      collection_description: "Test collection",
      text: text,
      metadata: %{
        "managed_by" => Inventory.managed_by(),
        "source_type" => "documentation",
        "title" => source_id,
        "content_hash" => hash_for(text)
      }
    }
  end

  defp hash_for(text) do
    :crypto.hash(:sha256, :erlang.term_to_binary(text))
    |> Base.encode16(case: :lower)
  end

  defp managed_doc_count(collection_name) do
    managed_by = Inventory.managed_by()

    from(d in Document,
      join: c in assoc(d, :collection),
      where: c.name == ^collection_name,
      where: fragment("?->>'managed_by' = ?", d.metadata, ^managed_by),
      select: count(d.id)
    )
    |> Repo.one()
  end

  defp managed_hash_for(source_id) do
    managed_by = Inventory.managed_by()

    from(d in Document,
      join: c in assoc(d, :collection),
      where: d.source_id == ^source_id,
      where: fragment("?->>'managed_by' = ?", d.metadata, ^managed_by),
      order_by: [desc: d.inserted_at],
      limit: 1,
      select: d.metadata
    )
    |> Repo.one()
    |> Map.fetch!("content_hash")
  end
end
