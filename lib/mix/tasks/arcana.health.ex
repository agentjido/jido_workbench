defmodule Mix.Tasks.Arcana.Health do
  @moduledoc """
  Runs Arcana health checks focused on cloud-safe, low-resource operation.

  Checks:
  - Arcana embedder is not local Nx/Bumblebee.
  - GraphRAG config does not fall back to local NER extractors.
  - GraphRAG + LLM configuration consistency.
  - Embedding dimension alignment between embedder and DB column.
  - Corpus and graph table counts.

  ## Examples

      mix arcana.health
      mix arcana.health --strict
  """
  use Mix.Task

  import Ecto.Query

  alias Arcana.{Chunk, Document}
  alias Ecto.Adapters.SQL

  @shortdoc "Arcana setup/corpus health checks"
  @switches [strict: :boolean]

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _argv, _invalid} = OptionParser.parse(args, strict: @switches)
    strict = Keyword.get(opts, :strict, false)
    repo = AgentJido.Repo

    embedder = Application.get_env(:arcana, :embedder, :openai)
    graph_cfg = normalize_graph_cfg(Application.get_env(:arcana, :graph, []))
    llm = Application.get_env(:arcana, :llm)
    graph_enabled = Map.get(graph_cfg, :enabled, false)
    graph_extractor = Map.get(graph_cfg, :extractor)
    graph_entity_extractor = Map.get(graph_cfg, :entity_extractor)

    {embedding_info, embedding_info_error} = safe_call(fn -> Arcana.Maintenance.embedding_info() end)

    {db_dims, db_dims_error} = resolve_db_embedding_dimensions(repo)

    issues =
      []
      |> maybe_add(local_embedder?(embedder), "Arcana local embedder is configured (Nx/EXLA path).")
      |> maybe_add(
        graph_enabled and is_nil(llm),
        "GraphRAG is enabled but Arcana LLM is not configured."
      )
      |> maybe_add(
        graph_enabled and is_nil(graph_extractor),
        "GraphRAG is enabled without an extractor; Arcana may fall back to local NER."
      )
      |> maybe_add(
        graph_enabled and not graph_llm_extractor?(graph_extractor),
        "GraphRAG extractor is not LLM-based; verify this does not use Nx locally."
      )
      |> maybe_add(
        graph_enabled and not graph_llm_entity_extractor?(graph_entity_extractor),
        "GraphRAG entity extractor is not LLM-based; graph query enhancement may fall back to local NER."
      )
      |> maybe_add(not is_nil(embedding_info_error), "Failed to read Arcana embedder info: #{embedding_info_error}")
      |> maybe_add(not is_nil(db_dims_error), "Failed to inspect DB embedding dimensions: #{db_dims_error}")
      |> maybe_add(
        dims_mismatch?(embedding_info, db_dims),
        "Embedder dimensions (#{inspect(embedding_info[:dimensions])}) do not match DB vector dimensions (#{inspect(db_dims)})."
      )

    {docs_count, docs_error} = safe_count(repo, from(d in Document, select: count(d.id)))
    {chunks_count, chunks_error} = safe_count(repo, from(ch in Chunk, select: count(ch.id)))
    {entities_count, entities_error} = safe_count(repo, from(e in "arcana_graph_entities", select: count(e.id)))
    {rels_count, rels_error} = safe_count(repo, from(r in "arcana_graph_relationships", select: count(r.id)))

    {communities_count, communities_error} =
      safe_count(repo, from(c in "arcana_graph_communities", select: count(c.id)))

    {dirty_count, dirty_error} =
      safe_count(
        repo,
        from(c in "arcana_graph_communities", where: c.dirty == true, select: count(c.id))
      )

    {summarized_count, summarized_error} =
      safe_count(
        repo,
        from(c in "arcana_graph_communities",
          where: not is_nil(c.summary) and c.summary != "",
          select: count(c.id)
        )
      )

    warnings =
      []
      |> maybe_add(not is_nil(docs_error), "Could not count documents: #{docs_error}")
      |> maybe_add(not is_nil(chunks_error), "Could not count chunks: #{chunks_error}")
      |> maybe_add(not is_nil(entities_error), "Could not count graph entities: #{entities_error}")
      |> maybe_add(not is_nil(rels_error), "Could not count graph relationships: #{rels_error}")
      |> maybe_add(not is_nil(communities_error), "Could not count graph communities: #{communities_error}")
      |> maybe_add(not is_nil(dirty_error), "Could not count dirty communities: #{dirty_error}")
      |> maybe_add(not is_nil(summarized_error), "Could not count summarized communities: #{summarized_error}")

    print_report(%{
      embedder: embedder,
      embedding_info: embedding_info,
      db_dims: db_dims,
      graph_enabled: graph_enabled,
      graph_extractor: graph_extractor,
      graph_entity_extractor: graph_entity_extractor,
      llm: llm,
      docs_count: docs_count,
      chunks_count: chunks_count,
      entities_count: entities_count,
      rels_count: rels_count,
      communities_count: communities_count,
      dirty_count: dirty_count,
      summarized_count: summarized_count,
      warnings: warnings,
      issues: issues
    })

    if issues != [] or (strict and warnings != []) do
      Mix.raise("Arcana health check failed (issues: #{length(issues)}, warnings: #{length(warnings)})")
    end
  end

  defp print_report(report) do
    shell = Mix.shell()

    shell.info("Arcana Health")
    Enum.each(report_lines(report), &shell.info/1)
    Enum.each(report.warnings, &shell.error("WARNING: " <> &1))
    Enum.each(report.issues, &shell.error("ISSUE: " <> &1))
    shell.info("status: #{report_status(report)}")
  end

  defp report_lines(report) do
    [
      "embedder_config: #{inspect(report.embedder)}",
      "embedder_info: #{inspect(report.embedding_info)}",
      "db_embedding_dimensions: #{inspect(report.db_dims)}",
      "graph_enabled: #{inspect(report.graph_enabled)}",
      "graph_extractor: #{inspect(report.graph_extractor)}",
      "graph_entity_extractor: #{inspect(report.graph_entity_extractor)}",
      "llm_configured: #{inspect(not is_nil(report.llm))}",
      "documents: #{format_count(report.docs_count)}",
      "chunks: #{format_count(report.chunks_count)}",
      "graph_entities: #{format_count(report.entities_count)}",
      "graph_relationships: #{format_count(report.rels_count)}",
      "graph_communities: #{format_count(report.communities_count)}",
      "graph_communities_dirty: #{format_count(report.dirty_count)}",
      "graph_communities_summarized: #{format_count(report.summarized_count)}"
    ]
  end

  defp report_status(%{issues: [], warnings: []}), do: "healthy"
  defp report_status(_report), do: "unhealthy"

  defp local_embedder?(embedder) do
    match?(:local, embedder) or
      match?({:local, _opts}, embedder) or
      match?(Arcana.Embedder.Local, embedder) or
      match?({Arcana.Embedder.Local, _opts}, embedder)
  end

  defp graph_llm_extractor?(extractor) do
    match?(Arcana.Graph.GraphExtractor.LLM, extractor) or
      match?({Arcana.Graph.GraphExtractor.LLM, _opts}, extractor)
  end

  defp graph_llm_entity_extractor?(extractor) do
    match?(Arcana.Graph.EntityExtractor.LLM, extractor) or
      match?({Arcana.Graph.EntityExtractor.LLM, _opts}, extractor)
  end

  defp normalize_graph_cfg(cfg) when is_list(cfg), do: Map.new(cfg)
  defp normalize_graph_cfg(cfg) when is_map(cfg), do: cfg
  defp normalize_graph_cfg(_other), do: %{}

  defp dims_mismatch?(embedding_info, db_dims) do
    is_integer(embedding_info[:dimensions]) and
      is_integer(db_dims) and
      embedding_info[:dimensions] != db_dims
  end

  defp resolve_db_embedding_dimensions(repo) do
    sql = """
    SELECT pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_attribute a
    JOIN pg_class c ON c.oid = a.attrelid
    WHERE c.relname = 'arcana_chunks'
      AND a.attname = 'embedding'
      AND a.attnum > 0
      AND NOT a.attisdropped
    LIMIT 1
    """

    case safe_call(fn -> SQL.query(repo, sql, []) end) do
      {{:ok, result}, nil} ->
        with {:ok, type_text} <- parse_column_type(result),
             {:ok, dims} <- parse_vector_dims(type_text) do
          {dims, nil}
        else
          {:error, reason} -> {nil, reason}
        end

      {{:error, reason}, nil} ->
        {nil, inspect(reason)}

      {_result, error} ->
        {nil, error}
    end
  end

  defp parse_column_type(%{rows: [[value]]}) when is_binary(value), do: {:ok, value}
  defp parse_column_type(%{rows: []}), do: {:error, "arcana_chunks.embedding column not found"}
  defp parse_column_type(_other), do: {:error, "unexpected embedding column query result"}

  defp parse_vector_dims(type_text) do
    case Regex.run(~r/vector\((\d+)\)/, type_text) do
      [_, raw] -> {:ok, String.to_integer(raw)}
      _ -> {:error, "unable to parse vector dimensions from #{inspect(type_text)}"}
    end
  end

  defp safe_count(repo, query) do
    safe_call(fn -> repo.one(query) end)
  end

  defp safe_call(fun) do
    {fun.(), nil}
  rescue
    error -> {nil, Exception.message(error)}
  catch
    kind, reason -> {nil, "#{kind}: #{inspect(reason)}"}
  end

  defp maybe_add(list, true, value), do: [value | list]
  defp maybe_add(list, false, _value), do: list

  defp format_count(nil), do: "n/a"
  defp format_count(value), do: to_string(value)
end
