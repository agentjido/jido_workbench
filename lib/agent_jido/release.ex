defmodule AgentJido.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :agent_jido

  @spec migrate() :: :ok | no_return()
  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  @doc """
  Runs DB migrations and Arcana content indexing in one release step.
  """
  @spec migrate_and_ingest() :: :ok | no_return()
  def migrate_and_ingest do
    :ok = migrate()
    :ok = ingest_content()
    :ok
  end

  @spec rollback(module(), integer()) :: :ok | no_return()
  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    :ok
  end

  @spec create_db() :: :ok | {:error, term()}
  def create_db do
    load_app()

    for repo <- repos() do
      case repo.__adapter__().storage_up(repo.config()) do
        :ok -> :ok
        {:error, :already_up} -> :ok
        {:error, term} -> {:error, term}
      end
    end
  end

  @doc """
  Runs production Arcana content indexing for static first-party content.

  This operation is idempotent and safe to run on every release.
  """
  @spec ingest_content() :: :ok | no_return()
  def ingest_content do
    load_app()

    {:ok, _} = Application.ensure_all_started(@app)

    repo = arcana_repo!()
    graph_enabled = graph_enabled?()
    graph_concurrency = env_integer("ARCANA_RELEASE_GRAPH_CONCURRENCY", 1)

    IO.puts("Arcana ingest: graph=#{graph_enabled} graph_concurrency=#{graph_concurrency} repo=#{inspect(repo)}")

    summary =
      AgentJido.ContentIngest.sync(
        repo: repo,
        dry_run: false,
        graph: graph_enabled,
        graph_concurrency: graph_concurrency
      )

    if summary.failed_count > 0 do
      raise "Arcana ingest failed with #{summary.failed_count} source failure(s)"
    end

    IO.puts("Arcana ingest complete: inserted=#{summary.inserted} updated=#{summary.updated} skipped=#{summary.skipped} deleted=#{summary.deleted}")

    if graph_enabled and env_boolean("ARCANA_RELEASE_REBUILD_COMMUNITIES", true) do
      rebuild_communities!(repo, graph_concurrency)
    end

    :ok
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp arcana_repo! do
    Application.get_env(:arcana, :repo) || hd(repos())
  end

  defp graph_enabled? do
    graph_cfg = graph_config()

    Keyword.get(graph_cfg, :enabled, false)
  end

  defp graph_config do
    case Application.get_env(:arcana, :graph, []) do
      cfg when is_list(cfg) -> cfg
      cfg when is_map(cfg) -> Map.to_list(cfg)
      _other -> []
    end
  end

  defp rebuild_communities!(repo, summarize_concurrency) do
    graph_cfg = graph_config()
    resolution = normalize_float(Keyword.get(graph_cfg, :resolution, 1.0), 1.0)
    max_level = normalize_integer(Keyword.get(graph_cfg, :community_levels, 1), 1)

    IO.puts("Arcana graph detection: resolution=#{resolution} max_level=#{max_level}")

    {:ok, detect_result} =
      Arcana.Maintenance.detect_communities(repo, resolution: resolution, max_level: max_level)

    IO.puts("Arcana graph detection complete: collections=#{detect_result.collections} communities=#{detect_result.communities}")

    IO.puts("Arcana graph summarization: concurrency=#{summarize_concurrency}")

    {:ok, summarize_result} =
      Arcana.Maintenance.summarize_communities(repo, concurrency: summarize_concurrency)

    IO.puts("Arcana graph summarization complete: communities=#{summarize_result.communities} summaries=#{summarize_result.summaries}")
  end

  defp env_boolean(name, default) do
    case System.get_env(name) do
      nil -> default
      value -> String.downcase(value) in ["1", "true", "yes", "on"]
    end
  end

  defp env_integer(name, default) do
    case System.get_env(name) do
      nil ->
        default

      value ->
        case Integer.parse(value) do
          {int, ""} when int > 0 -> int
          _other -> default
        end
    end
  end

  defp normalize_integer(value, _fallback) when is_integer(value) and value > 0, do: value
  defp normalize_integer(_value, fallback), do: fallback

  defp normalize_float(value, _fallback) when is_float(value), do: value
  defp normalize_float(value, _fallback) when is_integer(value), do: value * 1.0
  defp normalize_float(_value, fallback), do: fallback
end
