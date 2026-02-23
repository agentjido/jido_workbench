defmodule Mix.Tasks.Content.Ontology.Export do
  @moduledoc """
  Export the AgentJido content graph as Turtle (OWL-aligned data graph).

  Examples:

      mix content.ontology.export
      mix content.ontology.export --output tmp/agentjido-content-graph.ttl
      mix content.ontology.export --no-include-content-plan
      mix content.ontology.export --include-non-routable
  """

  use Mix.Task

  alias AgentJido.ContentOntology.Exporter

  @shortdoc "Export AgentJido content ontology graph to Turtle"

  @switches [
    output: :string,
    include_content_plan: :boolean,
    include_non_routable: :boolean
  ]

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    Mix.Task.run("compile")

    {opts, _argv, invalid} = OptionParser.parse(args, strict: @switches)

    if invalid != [] do
      Mix.raise("Invalid options: #{inspect(invalid)}")
    end

    export_opts =
      [
        output: Keyword.get(opts, :output, "tmp/agentjido-content-graph.ttl"),
        include_content_plan: Keyword.get(opts, :include_content_plan, true),
        include_non_routable: Keyword.get(opts, :include_non_routable, false)
      ]

    case Exporter.export(export_opts) do
      {:ok, summary} ->
        Mix.shell().info("Ontology graph export complete")
        Mix.shell().info("Path: #{summary.path}")
        Mix.shell().info("Generated at: #{DateTime.to_iso8601(summary.generated_at)}")
        Mix.shell().info("Web documents: #{summary.web_documents}")
        Mix.shell().info("Source documents: #{summary.source_documents}")
        Mix.shell().info("Content-plan entries: #{summary.content_plan_entries}")
        Mix.shell().info("Tags: #{summary.tags}")
        Mix.shell().info("Version nodes: #{summary.versions}")
        Mix.shell().info("Triples: #{summary.triples}")
        :ok

      {:error, reason} ->
        Mix.raise(reason)
    end
  end
end
