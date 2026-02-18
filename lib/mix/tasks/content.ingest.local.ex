defmodule Mix.Tasks.Content.Ingest.Local do
  @moduledoc """
  Ingest local first-party content into Arcana collections.

  Examples:

      mix content.ingest.local
      mix content.ingest.local --dry-run
      mix content.ingest.local --only docs,blog
      mix content.ingest.local --no-graph
      mix content.ingest.local --graph-concurrency 1
  """
  use Mix.Task

  alias AgentJido.ContentIngest
  alias AgentJido.ContentIngest.Inventory

  @shortdoc "Ingest local documentation/blog/ecosystem content into Arcana"

  @switches [dry_run: :boolean, only: :string, graph: :boolean, graph_concurrency: :integer]

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _argv, _invalid} = OptionParser.parse(args, strict: @switches)

    only = parse_only(opts[:only])
    dry_run = Keyword.get(opts, :dry_run, false)
    graph = Keyword.get(opts, :graph)
    graph_concurrency = Keyword.get(opts, :graph_concurrency)

    if not is_nil(graph_concurrency) and (not is_integer(graph_concurrency) or graph_concurrency <= 0) do
      Mix.raise("--graph-concurrency must be a positive integer")
    end

    sync_opts =
      [
        repo: AgentJido.Repo,
        dry_run: dry_run,
        only: only
      ]
      |> maybe_put_graph(graph)
      |> maybe_put_graph_concurrency(graph_concurrency)

    summary =
      ContentIngest.sync(sync_opts)

    print_summary(summary)

    if summary.failed_count > 0 do
      Mix.raise("Ingestion completed with #{summary.failed_count} failure(s)")
    end
  end

  defp parse_only(nil), do: nil

  defp parse_only(raw) when is_binary(raw) do
    valid_map =
      Inventory.valid_scopes()
      |> Enum.map(fn scope -> {Atom.to_string(scope), scope} end)
      |> Map.new()

    raw
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn scope ->
      case Map.fetch(valid_map, scope) do
        {:ok, value} ->
          value

        :error ->
          valid_values = valid_map |> Map.values() |> Enum.sort()

          raise ArgumentError,
                "invalid --only scope #{inspect(scope)}. Expected one of #{inspect(valid_values)}"
      end
    end)
  end

  defp print_summary(summary) do
    Mix.shell().info("Arcana local ingestion summary")
    Mix.shell().info("mode: #{summary.mode}")
    Mix.shell().info("graph: #{summary.graph}")
    Mix.shell().info("graph_concurrency: #{summary.graph_concurrency}")
    Mix.shell().info("collections: #{Enum.join(summary.collections, ", ")}")
    Mix.shell().info("sources: #{summary.total_sources}")
    Mix.shell().info("inserted: #{summary.inserted}")
    Mix.shell().info("updated: #{summary.updated}")
    Mix.shell().info("skipped: #{summary.skipped}")
    Mix.shell().info("deleted: #{summary.deleted}")
    Mix.shell().info("failed: #{summary.failed_count}")

    Enum.reverse(summary.failed)
    |> Enum.each(fn {source_id, reason} ->
      Mix.shell().error("  - #{source_id}: #{inspect(reason)}")
    end)
  end

  defp maybe_put_graph(opts, value) when is_boolean(value), do: Keyword.put(opts, :graph, value)
  defp maybe_put_graph(opts, _value), do: opts

  defp maybe_put_graph_concurrency(opts, value) when is_integer(value),
    do: Keyword.put(opts, :graph_concurrency, value)

  defp maybe_put_graph_concurrency(opts, _value), do: opts
end
