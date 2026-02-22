defmodule Mix.Tasks.Content.Simple.Generate do
  @moduledoc """
  Simple one-entry content generator for local iteration.

  This task intentionally keeps the workflow minimal and linear:

    1. Load brief
    2. Plan structure (LLM)
    3. Generate draft (LLM)
    4. Write page file
    5. Optionally run Livebook ExUnit test

  Examples:

      mix content.simple.generate --entry docs/agents
      mix content.simple.generate --entry docs/agents --dry-run
      mix content.simple.generate --entry docs/agents --run-livebook-test
      mix content.simple.generate --entry docs/agents --docs-format livemd
  """

  use Mix.Task

  alias AgentJido.ContentGen.SimpleOrchestrator

  @shortdoc "Simple one-entry docs generation flow (brief -> page)"

  @switches [
    entry: :string,
    dry_run: :boolean,
    docs_format: :string,
    planner_model: :string,
    writer_model: :string,
    run_livebook_test: :boolean
  ]

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    Mix.Task.run("compile")

    {opts, _argv, invalid} = OptionParser.parse(args, strict: @switches)

    if invalid != [] do
      Mix.raise("Invalid options: #{inspect(invalid)}")
    end

    run_opts = normalize_opts(opts)
    orchestrator = Application.get_env(:agent_jido, :content_simple_orchestrator, SimpleOrchestrator)
    logger = fn message -> Mix.shell().info(message) end

    case orchestrator.run(run_opts, log: logger) do
      {:ok, result} ->
        print_summary(result)
        :ok

      {:error, reason} ->
        Mix.raise("simple content generation failed: #{reason}")
    end
  end

  defp normalize_opts(opts) do
    entry = normalize_required_entry(Keyword.get(opts, :entry))

    %{
      entry: entry,
      dry_run: Keyword.get(opts, :dry_run, false),
      docs_format: parse_docs_format(Keyword.get(opts, :docs_format), entry),
      planner_model: normalize_optional(Keyword.get(opts, :planner_model)),
      writer_model: normalize_optional(Keyword.get(opts, :writer_model)),
      run_livebook_test: Keyword.get(opts, :run_livebook_test, false)
    }
  end

  defp normalize_required_entry(nil), do: Mix.raise("--entry is required (example: --entry docs/agents)")

  defp normalize_required_entry(entry) do
    case normalize_optional(entry) do
      nil -> Mix.raise("--entry is required (example: --entry docs/agents)")
      value -> value
    end
  end

  defp normalize_optional(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_optional(_), do: nil

  defp parse_docs_format(nil, entry) do
    if String.starts_with?(entry, "docs/"), do: :livemd, else: :tag
  end

  defp parse_docs_format("livemd", _entry), do: :livemd
  defp parse_docs_format("tag", _entry), do: :tag

  defp parse_docs_format(other, entry) when is_binary(other),
    do: other |> String.trim() |> String.downcase() |> parse_docs_format(entry)

  defp parse_docs_format(other, _entry),
    do: Mix.raise("Unknown --docs-format value #{inspect(other)} (expected tag|livemd)")

  defp print_summary(result) do
    Mix.shell().info("Status: success")
    Mix.shell().info("Entry: #{result.entry_id}")
    Mix.shell().info("Route: #{result.route}")
    Mix.shell().info("Target: #{result.target_path}")
    Mix.shell().info("Format: #{result.format}")
    Mix.shell().info("Parse mode: #{result.parse_mode}")
    Mix.shell().info("Dry run: #{result.dry_run}")
    Mix.shell().info("Written: #{result.written?}")
    Mix.shell().info("Planner model: #{result.planner_model || "(default)"}")
    Mix.shell().info("Writer model: #{result.writer_model || "(default)"}")

    if is_binary(result.livebook_test_file) do
      Mix.shell().info("Livebook test: #{result.livebook_test_file}")
    end

    if result.warnings != [] do
      Mix.shell().info("Warnings:")

      Enum.each(result.warnings, fn warning ->
        Mix.shell().info("  - #{warning}")
      end)
    end
  end
end
