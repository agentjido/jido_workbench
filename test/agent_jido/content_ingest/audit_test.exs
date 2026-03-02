defmodule AgentJido.ContentIngest.AuditTest do
  use AgentJido.DataCase, async: false

  alias AgentJido.ContentIngest.Audit
  alias AgentJido.ContentIngest.Ingestor
  alias AgentJido.ContentIngest.Inventory
  alias AgentJido.ContentIngest.Source

  describe "expected_sources/1" do
    test "builds expected snapshot rows from inventory sources" do
      alpha =
        source("docs:/alpha", "audit_docs", "alpha body",
          title: "Alpha",
          path: "/docs/alpha"
        )

      beta =
        source("blog:beta", "audit_blog", "beta body",
          title: "Beta",
          path: "/blog/beta"
        )

      rows = Audit.expected_sources(sources: [alpha, beta])

      assert Enum.map(rows, & &1.source_id) == ["blog:beta", "docs:/alpha"]

      assert Enum.any?(rows, fn row ->
               row.source_id == "docs:/alpha" and
                 row.collection == "audit_docs" and
                 row.title == "Alpha" and
                 row.path == "/docs/alpha" and
                 is_binary(row.content_hash)
             end)
    end
  end

  describe "ingested_sources/1" do
    test "returns latest per-source document with chunk counts" do
      source = source("docs:/ingested", "audit_docs_ingested", "ingested body token")

      summary = Ingestor.sync(repo: Repo, sources: [source], reconcile_stale: false)
      assert summary.inserted == 1

      [row] = Audit.ingested_sources(repo: Repo, collections: ["audit_docs_ingested"])
      assert row.source_id == source.source_id
      assert row.collection == source.collection
      assert row.content_hash == source.metadata["content_hash"]
      assert row.actual_chunk_count > 0
      assert row.duplicate_count == 0
    end
  end

  describe "compare_sources/2" do
    test "classifies missing, stale, mismatch, duplicate, unhealthy, and orphaned rows" do
      expected = [
        expected("docs:/ok", "site_docs", "ok-hash"),
        expected("docs:/missing", "site_docs", "missing-hash"),
        expected("docs:/stale", "site_docs", "new-hash"),
        expected("docs:/mismatch", "site_docs", "same-hash"),
        expected("docs:/dup", "site_docs", "dup-hash"),
        expected("docs:/err", "site_docs", "err-hash")
      ]

      ingested = [
        ingested("docs:/ok", "site_docs", "ok-hash", 1, nil, 0),
        ingested("docs:/stale", "site_docs", "old-hash", 1, nil, 0),
        ingested("docs:/mismatch", "site_blog", "same-hash", 1, nil, 0),
        ingested("docs:/dup", "site_docs", "dup-hash", 1, nil, 2),
        ingested("docs:/err", "site_docs", "err-hash", 0, "embedding failed", 0),
        ingested("docs:/orphan", "site_docs", "orphan-hash", 1, nil, 0)
      ]

      %{rows: rows, summary: summary} = Audit.compare_sources(expected, ingested)
      rows_by_id = Map.new(rows, &{&1.source_id, &1})

      assert rows_by_id["docs:/ok"].status == :ok
      assert rows_by_id["docs:/missing"].status == :missing
      assert rows_by_id["docs:/stale"].status == :stale_hash
      assert rows_by_id["docs:/mismatch"].status == :collection_mismatch
      assert rows_by_id["docs:/dup"].status == :duplicate_source_id
      assert rows_by_id["docs:/err"].status == :errored_or_unchunked
      assert rows_by_id["docs:/orphan"].status == :orphaned

      assert summary.expected_count == 6
      assert summary.ingested_count == 6
      assert summary.compared_count == 7
      assert summary.ok_count == 1
      assert summary.issue_counts.missing == 1
      assert summary.issue_counts.stale_hash == 1
      assert summary.issue_counts.collection_mismatch == 1
      assert summary.issue_counts.duplicate_source_id == 1
      assert summary.issue_counts.errored_or_unchunked == 1
      assert summary.issue_counts.orphaned == 1
    end
  end

  describe "audit/1 and source_report/2" do
    test "builds expected-vs-ingested report and supports source lookups" do
      collection = "audit_docs_report"

      ok_source = source("docs:/ok", collection, "ok body")
      stale_old = source("docs:/stale", collection, "old stale body")
      orphan = source("docs:/orphan", collection, "orphan body")

      ingest_summary =
        Ingestor.sync(
          repo: Repo,
          sources: [ok_source, stale_old, orphan],
          reconcile_stale: false
        )

      assert ingest_summary.inserted == 3

      stale_expected = source("docs:/stale", collection, "new stale body")
      missing_expected = source("docs:/missing", collection, "missing body")

      report =
        Audit.audit(
          repo: Repo,
          sources: [ok_source, stale_expected, missing_expected]
        )

      rows_by_id = Map.new(report.rows, &{&1.source_id, &1})

      assert rows_by_id["docs:/ok"].status == :ok
      assert rows_by_id["docs:/stale"].status == :stale_hash
      assert rows_by_id["docs:/missing"].status == :missing
      assert rows_by_id["docs:/orphan"].status == :orphaned

      assert report.summary.issue_counts.stale_hash == 1
      assert report.summary.issue_counts.missing == 1
      assert report.summary.issue_counts.orphaned == 1

      stale_row =
        Audit.source_report("docs:/stale",
          repo: Repo,
          sources: [ok_source, stale_expected, missing_expected]
        )

      assert stale_row.status == :stale_hash
      assert stale_row.expected.source_id == "docs:/stale"
      assert stale_row.ingested.source_id == "docs:/stale"
    end
  end

  defp source(source_id, collection, text, attrs \\ []) do
    metadata =
      %{
        "managed_by" => Inventory.managed_by(),
        "source_type" => "documentation",
        "title" => Keyword.get(attrs, :title, source_id),
        "path" => Keyword.get(attrs, :path, source_id),
        "url" => Keyword.get(attrs, :path, source_id),
        "content_hash" => hash_for(text)
      }

    %Source{
      source_id: source_id,
      collection: collection,
      collection_description: "Audit collection",
      text: text,
      metadata: metadata
    }
  end

  defp expected(source_id, collection, content_hash) do
    %{
      source_id: source_id,
      collection: collection,
      content_hash: content_hash,
      title: source_id,
      path: source_id,
      metadata: %{"content_hash" => content_hash}
    }
  end

  defp ingested(source_id, collection, content_hash, actual_chunk_count, document_error, duplicate_count) do
    %{
      source_id: source_id,
      collection: collection,
      document_id: Ecto.UUID.generate(),
      content_hash: content_hash,
      title: source_id,
      path: source_id,
      metadata: %{"content_hash" => content_hash},
      document_status: "indexed",
      document_error: document_error,
      declared_chunk_count: actual_chunk_count,
      actual_chunk_count: actual_chunk_count,
      updated_at: DateTime.utc_now(),
      duplicate_count: duplicate_count,
      duplicate_document_ids: []
    }
  end

  defp hash_for(text) do
    :crypto.hash(:sha256, :erlang.term_to_binary(text))
    |> Base.encode16(case: :lower)
  end
end
