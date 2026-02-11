defmodule AgentJido.ContentIngest.Ingestor do
  @moduledoc """
  Idempotent Arcana synchronization for locally managed content.
  """

  import Ecto.Query

  alias AgentJido.ContentIngest.Inventory
  alias AgentJido.ContentIngest.Source
  alias Arcana.Collection
  alias Arcana.Document

  @doc """
  Synchronizes managed sources into Arcana.

  ## Options

    * `:repo` - Ecto repo (defaults to Arcana `:repo` config)
    * `:dry_run` - If true, computes actions without writing
    * `:only` - Scope list from `Inventory.valid_scopes/0`
    * `:sources` - Explicit source list (for tests)
    * `:managed_collections` - Explicit collection names to reconcile stale docs

  Returns a summary map.
  """
  @spec sync(keyword()) :: map()
  def sync(opts \\ []) do
    repo = require_repo!(opts)
    dry_run = Keyword.get(opts, :dry_run, false)
    sources = Keyword.get(opts, :sources, Inventory.build(only: Keyword.get(opts, :only)))

    validate_sources!(sources)

    collection_names =
      Keyword.get_lazy(opts, :managed_collections, fn ->
        sources
        |> Enum.map(& &1.collection)
      end)
      |> Enum.uniq()

    existing_docs = fetch_existing_managed_documents(repo, collection_names)

    existing_by_source =
      existing_docs
      |> Enum.group_by(& &1.source_id)

    source_ids =
      sources
      |> Enum.map(& &1.source_id)
      |> MapSet.new()

    summary =
      Enum.reduce(sources, base_summary(sources, collection_names, dry_run), fn source, acc ->
        docs = Map.get(existing_by_source, source.source_id, [])
        sync_source(repo, source, docs, acc)
      end)

    stale_docs = Enum.reject(existing_docs, &MapSet.member?(source_ids, &1.source_id))
    stale_ids = Enum.map(stale_docs, & &1.id)

    summary =
      if stale_ids == [] do
        summary
      else
        maybe_delete_documents(repo, stale_ids, dry_run)
        Map.update!(summary, :deleted, &(&1 + length(stale_ids)))
      end

    Map.put(summary, :failed_count, length(summary.failed))
  end

  defp sync_source(repo, %Source{} = source, docs, summary) do
    target_hash = metadata_value(source.metadata, "content_hash")

    {matching_docs, non_matching_docs} =
      Enum.split_with(docs, fn doc ->
        metadata_value(doc.metadata, "content_hash") == target_hash
      end)

    cond do
      docs == [] ->
        insert_source(repo, source, summary)

      matching_docs != [] ->
        keep_doc = hd(matching_docs)
        duplicate_ids = Enum.reject(docs, &(&1.id == keep_doc.id)) |> Enum.map(& &1.id)

        if duplicate_ids != [] do
          maybe_delete_documents(repo, duplicate_ids, summary.dry_run)
        end

        summary
        |> Map.update!(:skipped, &(&1 + 1))
        |> Map.update!(:deleted, &(&1 + length(duplicate_ids)))

      non_matching_docs != [] ->
        update_source(repo, source, docs, summary)
    end
  end

  defp insert_source(repo, source, summary) do
    case maybe_ingest_source(repo, source, summary.dry_run) do
      :ok ->
        Map.update!(summary, :inserted, &(&1 + 1))

      {:error, reason} ->
        add_failure(summary, source.source_id, reason)
    end
  end

  defp update_source(repo, source, docs, summary) do
    case maybe_ingest_source(repo, source, summary.dry_run) do
      :ok ->
        old_ids = Enum.map(docs, & &1.id)
        maybe_delete_documents(repo, old_ids, summary.dry_run)

        summary
        |> Map.update!(:updated, &(&1 + 1))
        |> Map.update!(:deleted, &(&1 + length(old_ids)))

      {:error, reason} ->
        add_failure(summary, source.source_id, reason)
    end
  end

  defp add_failure(summary, source_id, reason) do
    Map.update!(summary, :failed, &[{source_id, reason} | &1])
  end

  defp maybe_ingest_source(_repo, _source, true), do: :ok

  defp maybe_ingest_source(repo, source, false) do
    options = [
      repo: repo,
      source_id: source.source_id,
      metadata: source.metadata,
      collection: %{name: source.collection, description: source.collection_description},
      graph: false
    ]

    case Arcana.ingest(source.text, options) do
      {:ok, _document} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp maybe_delete_documents(_repo, _ids, true), do: :ok
  defp maybe_delete_documents(_repo, [], _dry_run), do: :ok

  defp maybe_delete_documents(repo, ids, false) do
    from(d in Document, where: d.id in ^ids)
    |> repo.delete_all()

    :ok
  end

  defp fetch_existing_managed_documents(_repo, []), do: []

  defp fetch_existing_managed_documents(repo, collection_names) do
    managed_by = Inventory.managed_by()

    query =
      from(d in Document,
        join: c in Collection,
        on: c.id == d.collection_id,
        where: c.name in ^collection_names,
        where: not is_nil(d.source_id),
        where: fragment("?->>'managed_by' = ?", d.metadata, ^managed_by),
        order_by: [desc: d.inserted_at],
        select: %{
          id: d.id,
          source_id: d.source_id,
          collection: c.name,
          metadata: d.metadata,
          inserted_at: d.inserted_at
        }
      )

    repo.all(query)
  end

  defp base_summary(sources, collection_names, dry_run) do
    %{
      mode: if(dry_run, do: :dry_run, else: :apply),
      dry_run: dry_run,
      total_sources: length(sources),
      collections: collection_names,
      inserted: 0,
      updated: 0,
      skipped: 0,
      deleted: 0,
      failed: []
    }
  end

  defp metadata_value(metadata, key) when is_map(metadata) do
    case Map.fetch(metadata, key) do
      {:ok, value} ->
        value

      :error ->
        Enum.find_value(metadata, fn
          {atom_key, value} when is_atom(atom_key) ->
            if Atom.to_string(atom_key) == key, do: value

          _other ->
            nil
        end)
    end
  end

  defp require_repo!(opts) do
    Keyword.get(opts, :repo) ||
      Application.get_env(:arcana, :repo) ||
      raise ArgumentError, "repo is required"
  end

  defp validate_sources!(sources) when is_list(sources) do
    case Enum.find(sources, &(not match?(%Source{}, &1))) do
      nil -> :ok
      invalid -> raise ArgumentError, "invalid source: #{inspect(invalid)}"
    end
  end
end
