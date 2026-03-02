defmodule AgentJido.ContentIngest.Audit do
  @moduledoc """
  Builds and compares ingestion snapshots keyed by `source_id`.

  This module provides:

    * expected snapshot (`expected_sources/1`) from `Inventory.build/1`
    * ingested snapshot (`ingested_sources/1`) from Arcana tables
    * comparison (`compare_sources/2`) with per-source status/issue labels
    * one-shot report (`audit/1`) and source lookup (`source_report/2`)
  """

  import Ecto.Query

  alias AgentJido.ContentIngest.Inventory
  alias AgentJido.ContentIngest.Source
  alias AgentJido.Repo
  alias Arcana.{Chunk, Collection, Document}

  @issue_order [
    :missing,
    :orphaned,
    :collection_mismatch,
    :stale_hash,
    :duplicate_source_id,
    :errored_or_unchunked
  ]

  @status_order [:ok | @issue_order]

  @typedoc "Per-source comparison issue."
  @type issue ::
          :missing
          | :orphaned
          | :collection_mismatch
          | :stale_hash
          | :duplicate_source_id
          | :errored_or_unchunked

  @typedoc "Primary per-source status."
  @type status :: :ok | issue()

  @type expected_source :: %{
          required(:source_id) => String.t(),
          required(:collection) => String.t(),
          required(:content_hash) => String.t() | nil,
          required(:title) => String.t() | nil,
          required(:path) => String.t() | nil,
          required(:metadata) => map()
        }

  @type ingested_source :: %{
          required(:source_id) => String.t(),
          required(:collection) => String.t() | nil,
          required(:document_id) => Ecto.UUID.t() | nil,
          required(:content_hash) => String.t() | nil,
          required(:title) => String.t() | nil,
          required(:path) => String.t() | nil,
          required(:metadata) => map(),
          required(:document_status) => String.t() | nil,
          required(:document_error) => String.t() | nil,
          required(:declared_chunk_count) => non_neg_integer(),
          required(:actual_chunk_count) => non_neg_integer(),
          required(:updated_at) => NaiveDateTime.t() | DateTime.t() | nil,
          required(:duplicate_count) => non_neg_integer(),
          required(:duplicate_document_ids) => [Ecto.UUID.t()]
        }

  @type comparison_row :: %{
          required(:source_id) => String.t(),
          required(:status) => status(),
          required(:issues) => [issue()],
          required(:expected) => expected_source() | nil,
          required(:ingested) => ingested_source() | nil
        }

  @type summary :: %{
          required(:expected_count) => non_neg_integer(),
          required(:ingested_count) => non_neg_integer(),
          required(:compared_count) => non_neg_integer(),
          required(:ok_count) => non_neg_integer(),
          required(:blocking_count) => non_neg_integer(),
          required(:issue_counts) => %{issue() => non_neg_integer()},
          required(:status_counts) => %{status() => non_neg_integer()}
        }

  @type report :: %{
          required(:expected) => [expected_source()],
          required(:ingested) => [ingested_source()],
          required(:rows) => [comparison_row()],
          required(:summary) => summary()
        }

  @doc """
  Builds expected + ingested snapshots and compares them.

  ## Options

    * `:repo` - Ecto repo (defaults to Arcana repo, then `AgentJido.Repo`)
    * `:only` - Inventory scopes (`[:docs, :blog, :ecosystem]`)
    * `:sources` - Explicit expected `t:Source.t/0` list
    * `:source_id` - Optional source id filter for targeted audits
    * `:collections` - Optional collection filter for ingested snapshot
    * `:managed_by` - Metadata marker filter (defaults to `Inventory.managed_by/0`)
  """
  @spec audit(keyword()) :: report()
  def audit(opts \\ []) do
    expected = expected_sources(opts)
    ingested = ingested_sources(infer_ingested_options(opts, expected))
    %{rows: rows, summary: summary} = compare_sources(expected, ingested)

    %{
      expected: expected,
      ingested: ingested,
      rows: rows,
      summary: summary
    }
  end

  @doc """
  Returns the expected content snapshot from inventory.
  """
  @spec expected_sources(keyword()) :: [expected_source()]
  def expected_sources(opts \\ []) do
    source_id_filter = normalize_source_id(Keyword.get(opts, :source_id))

    opts
    |> inventory_sources()
    |> Enum.map(&expected_from_source/1)
    |> maybe_filter_source_id_rows(source_id_filter)
    |> Enum.sort_by(&{&1.collection, &1.source_id})
  end

  @doc """
  Returns the currently ingested Arcana snapshot.
  """
  @spec ingested_sources(keyword()) :: [ingested_source()]
  def ingested_sources(opts \\ []) do
    repo = require_repo!(opts)
    managed_by = Keyword.get(opts, :managed_by, Inventory.managed_by())
    source_id_filter = normalize_source_id(Keyword.get(opts, :source_id))
    collections = normalize_collections(Keyword.get(opts, :collections))

    repo
    |> fetch_ingested_rows(managed_by, collections, source_id_filter)
    |> Enum.group_by(& &1.source_id)
    |> Enum.map(fn {source_id, docs} -> collapse_source_documents(source_id, docs) end)
    |> Enum.sort_by(&{&1.collection || "", &1.source_id})
  end

  @doc """
  Compares expected and ingested snapshots by `source_id`.
  """
  @spec compare_sources([expected_source()], [ingested_source()]) :: %{
          rows: [comparison_row()],
          summary: summary()
        }
  def compare_sources(expected_sources, ingested_sources)
      when is_list(expected_sources) and is_list(ingested_sources) do
    assert_unique_source_ids!(expected_sources, :expected_sources)
    assert_unique_source_ids!(ingested_sources, :ingested_sources)

    expected_by_id = Map.new(expected_sources, &{&1.source_id, &1})
    ingested_by_id = Map.new(ingested_sources, &{&1.source_id, &1})

    expected_rows =
      Enum.map(expected_sources, fn expected ->
        compare_expected_row(expected, Map.get(ingested_by_id, expected.source_id))
      end)

    orphan_rows =
      ingested_sources
      |> Enum.reject(&Map.has_key?(expected_by_id, &1.source_id))
      |> Enum.map(&orphan_row/1)

    rows =
      (expected_rows ++ orphan_rows)
      |> Enum.sort_by(&{status_rank(&1.status), &1.source_id})

    %{
      rows: rows,
      summary: summarize(rows, expected_sources, ingested_sources)
    }
  end

  @doc """
  Returns a single source comparison row for the given `source_id`.
  """
  @spec source_report(String.t(), keyword()) :: comparison_row() | nil
  def source_report(source_id, opts \\ [])

  def source_report(source_id, opts) when is_binary(source_id) do
    source_id = String.trim(source_id)

    if source_id == "" do
      nil
    else
      report =
        opts
        |> Keyword.put(:source_id, source_id)
        |> audit()

      Enum.find(report.rows, &(&1.source_id == source_id))
    end
  end

  def source_report(_source_id, _opts), do: nil

  defp inventory_sources(opts) do
    sources = Keyword.get(opts, :sources, Inventory.build(only: Keyword.get(opts, :only)))

    if Enum.all?(sources, &match?(%Source{}, &1)) do
      sources
    else
      raise ArgumentError, "expected :sources to be a list of %AgentJido.ContentIngest.Source{}"
    end
  end

  defp infer_ingested_options(opts, expected_sources) do
    has_collections? = Keyword.has_key?(opts, :collections)
    source_id_filter = normalize_source_id(Keyword.get(opts, :source_id))

    cond do
      has_collections? ->
        opts

      is_binary(source_id_filter) ->
        opts

      true ->
        inferred =
          expected_sources
          |> Enum.map(& &1.collection)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()

        if inferred == [] do
          opts
        else
          Keyword.put(opts, :collections, inferred)
        end
    end
  end

  defp expected_from_source(%Source{} = source) do
    metadata = source.metadata || %{}

    %{
      source_id: source.source_id,
      collection: source.collection,
      content_hash: metadata_value(metadata, "content_hash"),
      title: metadata_value(metadata, "title") || metadata_value(metadata, "name"),
      path: metadata_value(metadata, "path") || metadata_value(metadata, "url"),
      metadata: metadata
    }
  end

  defp fetch_ingested_rows(repo, managed_by, collections, source_id_filter) do
    query =
      from(d in Document,
        left_join: c in Collection,
        on: c.id == d.collection_id,
        left_join: ch in Chunk,
        on: ch.document_id == d.id,
        where: not is_nil(d.source_id),
        where: fragment("?->>'managed_by' = ?", d.metadata, ^managed_by),
        group_by: [d.id, d.source_id, d.metadata, d.status, d.error, d.chunk_count, d.updated_at, c.name],
        select: %{
          document_id: d.id,
          source_id: d.source_id,
          collection: c.name,
          metadata: d.metadata,
          document_status: d.status,
          document_error: d.error,
          declared_chunk_count: d.chunk_count,
          actual_chunk_count: count(ch.id),
          updated_at: d.updated_at
        }
      )
      |> maybe_filter_collections_query(collections)
      |> maybe_filter_source_id_query(source_id_filter)

    repo.all(query)
  end

  defp maybe_filter_collections_query(query, nil), do: query

  defp maybe_filter_collections_query(query, []), do: from([_d, _c, _ch] in query, where: false)

  defp maybe_filter_collections_query(query, collections),
    do: from([_d, c, _ch] in query, where: c.name in ^collections)

  defp maybe_filter_source_id_query(query, nil), do: query

  defp maybe_filter_source_id_query(query, source_id),
    do: from([d, _c, _ch] in query, where: d.source_id == ^source_id)

  defp collapse_source_documents(source_id, docs) do
    [latest | duplicates] =
      docs
      |> Enum.sort_by(&{updated_at_sort_key(&1.updated_at), to_string(&1.document_id)}, :desc)

    metadata = latest.metadata || %{}

    %{
      source_id: source_id,
      collection: latest.collection,
      document_id: latest.document_id,
      content_hash: metadata_value(metadata, "content_hash"),
      title: metadata_value(metadata, "title") || metadata_value(metadata, "name"),
      path: metadata_value(metadata, "path") || metadata_value(metadata, "url"),
      metadata: metadata,
      document_status: latest.document_status,
      document_error: latest.document_error,
      declared_chunk_count: normalize_count(latest.declared_chunk_count),
      actual_chunk_count: normalize_count(latest.actual_chunk_count),
      updated_at: latest.updated_at,
      duplicate_count: length(duplicates),
      duplicate_document_ids: Enum.map(duplicates, & &1.document_id)
    }
  end

  defp compare_expected_row(expected, nil) do
    %{
      source_id: expected.source_id,
      status: :missing,
      issues: [:missing],
      expected: expected,
      ingested: nil
    }
  end

  defp compare_expected_row(expected, ingested) do
    issues =
      []
      |> maybe_add_issue(collection_mismatch?(expected, ingested), :collection_mismatch)
      |> maybe_add_issue(hash_mismatch?(expected, ingested), :stale_hash)
      |> maybe_add_issue(duplicate_source_id?(ingested), :duplicate_source_id)
      |> maybe_add_issue(document_unhealthy?(ingested), :errored_or_unchunked)

    %{
      source_id: expected.source_id,
      status: if(issues == [], do: :ok, else: primary_issue(issues)),
      issues: issues,
      expected: expected,
      ingested: ingested
    }
  end

  defp orphan_row(ingested) do
    %{
      source_id: ingested.source_id,
      status: :orphaned,
      issues: [:orphaned],
      expected: nil,
      ingested: ingested
    }
  end

  defp summarize(rows, expected_sources, ingested_sources) do
    issue_counts =
      Enum.reduce(rows, zeroed_map(@issue_order), fn row, acc ->
        Enum.reduce(Enum.uniq(row.issues), acc, fn issue, issue_acc ->
          Map.update!(issue_acc, issue, &(&1 + 1))
        end)
      end)

    status_counts =
      @status_order
      |> zeroed_map()
      |> Map.merge(Enum.frequencies_by(rows, & &1.status))

    ok_count = Map.get(status_counts, :ok, 0)

    %{
      expected_count: length(expected_sources),
      ingested_count: length(ingested_sources),
      compared_count: length(rows),
      ok_count: ok_count,
      blocking_count: length(rows) - ok_count,
      issue_counts: issue_counts,
      status_counts: status_counts
    }
  end

  defp zeroed_map(values) do
    values
    |> Enum.map(&{&1, 0})
    |> Map.new()
  end

  defp primary_issue([issue | rest]) do
    [issue | rest]
    |> Enum.uniq()
    |> Enum.sort_by(&issue_rank/1)
    |> List.first()
  end

  defp issue_rank(issue) do
    Enum.find_index(@issue_order, &(&1 == issue)) || length(@issue_order)
  end

  defp status_rank(status) do
    Enum.find_index(@status_order, &(&1 == status)) || length(@status_order)
  end

  defp maybe_add_issue(issues, true, issue), do: issues ++ [issue]
  defp maybe_add_issue(issues, false, _issue), do: issues

  defp collection_mismatch?(expected, ingested) do
    is_binary(expected.collection) and is_binary(ingested.collection) and expected.collection != ingested.collection
  end

  defp hash_mismatch?(expected, ingested) do
    is_binary(expected.content_hash) and
      String.trim(expected.content_hash) != "" and
      is_binary(ingested.content_hash) and
      String.trim(ingested.content_hash) != "" and
      expected.content_hash != ingested.content_hash
  end

  defp duplicate_source_id?(ingested) do
    is_integer(ingested.duplicate_count) and ingested.duplicate_count > 0
  end

  defp document_unhealthy?(ingested) do
    error_present?(ingested.document_error) or
      status_error?(ingested.document_status) or
      unchunked?(ingested.actual_chunk_count)
  end

  defp error_present?(error), do: is_binary(error) and String.trim(error) != ""

  defp status_error?(status) when is_binary(status) do
    status
    |> String.downcase()
    |> then(&(&1 in ["error", "failed"]))
  end

  defp status_error?(_status), do: false

  defp unchunked?(actual_chunk_count), do: not is_integer(actual_chunk_count) or actual_chunk_count <= 0

  defp updated_at_sort_key(%DateTime{} = updated_at), do: DateTime.to_unix(updated_at, :microsecond)

  defp updated_at_sort_key(%NaiveDateTime{} = updated_at) do
    updated_at
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix(:microsecond)
  end

  defp updated_at_sort_key(_updated_at), do: 0

  defp normalize_count(count) when is_integer(count) and count >= 0, do: count
  defp normalize_count(_count), do: 0

  defp normalize_source_id(source_id) when is_binary(source_id) do
    source_id = String.trim(source_id)
    if source_id == "", do: nil, else: source_id
  end

  defp normalize_source_id(_source_id), do: nil

  defp maybe_filter_source_id_rows(rows, nil), do: rows
  defp maybe_filter_source_id_rows(rows, source_id), do: Enum.filter(rows, &(&1.source_id == source_id))

  defp normalize_collections(nil), do: nil

  defp normalize_collections(collections) when is_list(collections) do
    collections
    |> Enum.filter(&is_binary/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  defp normalize_collections(_other) do
    raise ArgumentError, "invalid :collections option (expected list of collection names)"
  end

  defp metadata_value(metadata, key) when is_map(metadata) and is_binary(key) do
    Map.get(metadata, key) || Map.get(metadata, String.to_existing_atom(key))
  rescue
    ArgumentError -> Map.get(metadata, key)
  end

  defp metadata_value(_metadata, _key), do: nil

  defp assert_unique_source_ids!(rows, label) do
    duplicates =
      rows
      |> Enum.map(& &1.source_id)
      |> Enum.frequencies()
      |> Enum.filter(fn {_source_id, count} -> count > 1 end)
      |> Enum.map(&elem(&1, 0))

    if duplicates == [] do
      :ok
    else
      raise ArgumentError,
            "#{label} contains duplicate source_id entries: #{inspect(Enum.sort(duplicates))}"
    end
  end

  defp require_repo!(opts) do
    case Keyword.get(opts, :repo) || Application.get_env(:arcana, :repo) || Repo do
      repo when is_atom(repo) ->
        repo

      other ->
        raise ArgumentError, "invalid :repo option: #{inspect(other)} (expected module atom)"
    end
  end
end
