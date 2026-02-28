defmodule Mix.Tasks.Content.Plan.Generate do
  @moduledoc """
  Generate site content from `priv/content_plan/**/*.md` briefs.

  Dry-run is the default. Use `--apply` to write files.

      mix content.plan.generate
      mix content.plan.generate --entry docs/reference-jido-action
      mix content.plan.generate --section docs,build --max 5
      mix content.plan.generate --apply --backend req_llm
      mix content.plan.generate --update-mode audit_only
  """

  use Mix.Task

  alias AgentJido.ContentGen
  alias AgentJido.ContentGen.Run
  alias AgentJido.ContentPlan

  @shortdoc "Generate page content from content-plan briefs (dry-run by default)"

  @switches [
    apply: :boolean,
    max: :integer,
    section: :keep,
    entry: :string,
    status: :keep,
    backend: :string,
    update_mode: :string,
    source_root: :string,
    report: :string,
    fail_on_audit: :boolean,
    verify: :boolean,
    docs_format: :string
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
    validate_verify_scope!(run_opts)
    ensure_backend_runtime!(run_opts)

    case Run.run(run_opts) do
      {:ok, report} ->
        print_summary(report)
        :ok

      {:error, report} ->
        print_summary(report)
        Mix.raise("content generation run failed. report: #{report.report_path}")
    end
  end

  defp normalize_opts(opts) do
    entry = normalize_entry(Keyword.get(opts, :entry))

    %{
      apply: Keyword.get(opts, :apply, false),
      max: normalize_max(Keyword.get(opts, :max, ContentGen.default_batch_size())),
      sections: parse_csv_values(Keyword.get_values(opts, :section)),
      entry: entry,
      statuses: parse_statuses(opts),
      backend: parse_backend(Keyword.get(opts, :backend, "auto")),
      update_mode: parse_update_mode(Keyword.get(opts, :update_mode, "improve")),
      source_root: Keyword.get(opts, :source_root, ".."),
      report: normalize_optional(Keyword.get(opts, :report)),
      fail_on_audit: normalize_fail_on_audit(opts),
      verify: Keyword.get(opts, :verify, false),
      docs_format: parse_docs_format(Keyword.get(opts, :docs_format), entry)
    }
  end

  defp normalize_max(max) when is_integer(max) and max > 0, do: max
  defp normalize_max(max), do: Mix.raise("Invalid --max value #{inspect(max)} (must be a positive integer)")

  defp normalize_entry(nil), do: nil
  defp normalize_entry(entry), do: normalize_optional(entry)

  defp normalize_optional(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_optional(_value), do: nil

  defp parse_statuses(opts) do
    status_values =
      opts
      |> Keyword.get_values(:status)
      |> parse_csv_values()

    if status_values == [] do
      ContentGen.default_statuses()
    else
      known_statuses =
        ContentPlan.all_entries()
        |> Enum.map(&{to_string(&1.status), &1.status})
        |> Map.new()

      Enum.map(status_values, fn value ->
        key = String.trim(value)

        case Map.fetch(known_statuses, key) do
          {:ok, atom_status} -> atom_status
          :error -> Mix.raise("Unknown --status value #{inspect(value)}")
        end
      end)
    end
  end

  defp parse_backend("auto"), do: :req_llm
  defp parse_backend("codex"), do: :req_llm
  defp parse_backend("req_llm"), do: :req_llm
  defp parse_backend(other) when is_binary(other), do: other |> String.trim() |> String.downcase() |> parse_backend()
  defp parse_backend(other), do: Mix.raise("Unknown --backend value #{inspect(other)} (expected auto|req_llm)")

  defp parse_update_mode("improve"), do: :improve
  defp parse_update_mode("regenerate"), do: :regenerate
  defp parse_update_mode("audit_only"), do: :audit_only

  defp parse_update_mode(other) when is_binary(other),
    do: other |> String.trim() |> String.downcase() |> parse_update_mode()

  defp parse_update_mode(other),
    do: Mix.raise("Unknown --update-mode value #{inspect(other)} (expected improve|regenerate|audit_only)")

  defp parse_docs_format(nil, entry) when is_binary(entry) do
    if String.starts_with?(entry, "docs/"), do: :livemd, else: :tag
  end

  defp parse_docs_format(nil, _entry), do: :tag
  defp parse_docs_format("tag", _entry), do: :tag
  defp parse_docs_format("livemd", _entry), do: :livemd

  defp parse_docs_format(other, entry) when is_binary(other),
    do: other |> String.trim() |> String.downcase() |> parse_docs_format(entry)

  defp parse_docs_format(other, _entry),
    do: Mix.raise("Unknown --docs-format value #{inspect(other)} (expected tag|livemd)")

  defp parse_csv_values(values) when is_list(values) do
    values
    |> Enum.flat_map(fn value ->
      value
      |> to_string()
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
    end)
    |> Enum.uniq()
  end

  defp normalize_fail_on_audit(opts) do
    if Keyword.has_key?(opts, :fail_on_audit) do
      Keyword.get(opts, :fail_on_audit, true)
    else
      true
    end
  end

  defp validate_verify_scope!(%{verify: false}), do: :ok

  defp validate_verify_scope!(%{verify: true, entry: nil}) do
    Mix.raise("--verify requires --entry docs/<id> (single-entry docs scope)")
  end

  defp validate_verify_scope!(%{verify: true, entry: entry}) when is_binary(entry) do
    case ContentPlan.get_entry(entry) do
      nil ->
        Mix.raise("--verify requires a valid content-plan entry id, got #{inspect(entry)}")

      %{section: "docs"} ->
        :ok

      %{section: section} ->
        Mix.raise("--verify is docs-only; #{inspect(entry)} is in section #{inspect(section)}")
    end
  end

  defp print_summary(report) do
    stats = report.stats || %{}

    Mix.shell().info("Run ID: #{report.run_id}")
    Mix.shell().info("Report: #{report.report_path}")
    Mix.shell().info("Selected: #{stats.selected || 0}")
    Mix.shell().info("Written: #{stats.written || 0}")
    Mix.shell().info("Dry-run candidates: #{stats.dry_run_candidates || 0}")
    Mix.shell().info("No-op skipped: #{stats.skipped_noop || 0}")
    Mix.shell().info("Non-file skipped: #{stats.skipped_non_file_target || 0}")
    Mix.shell().info("Audit failed: #{stats.audit_failed || 0}")
    Mix.shell().info("Generation failed: #{stats.generation_failed || 0}")
    Mix.shell().info("Parse failed: #{stats.parse_failed || 0}")
    Mix.shell().info("Churn blocked: #{stats.churn_blocked || 0}")
    Mix.shell().info("Verification failed: #{stats.verification_failed || 0}")

    if Map.get(report.options || %{}, :verify, false) do
      print_verify_summary(report)
    end
  end

  defp print_verify_summary(report) do
    Mix.shell().info("Verification details:")

    Enum.each(report.entries || [], fn entry ->
      verification = Map.get(entry, :verification, %{})
      check_results = Map.get(verification, :check_results, %{})

      Mix.shell().info("  Entry: #{entry.id}")
      Mix.shell().info("  Target: #{entry.target_path || "(none)"}")
      Mix.shell().info("  Audit status: #{check_result(check_results, :audit_only)}")
      Mix.shell().info("  Route render status: #{check_result(check_results, :route_render)}")
      Mix.shell().info("  Livebook test status: #{check_result(check_results, :livebook_test)}")
      Mix.shell().info("  Livebook test file: #{verification.livebook_test_file || "(none)"}")
      Mix.shell().info("  Verification status: #{verification.status || "skipped"}")

      if verification.status == "failed" do
        Mix.shell().info("  Remediation hint:")

        Mix.shell().info(
          "  #{String.slice(verification.command_output_excerpt || "fix audit/link/livebook issues and rerun --apply --verify", 0, 600)}"
        )
      end
    end)
  end

  defp check_result(check_results, key) do
    Map.get(check_results, key) || Map.get(check_results, Atom.to_string(key)) || "skipped"
  end

  defp ensure_backend_runtime!(%{backend: :req_llm}) do
    case Application.ensure_all_started(:req_llm) do
      {:ok, _apps} -> :ok
      {:error, reason} -> Mix.raise("failed to start req_llm runtime: #{inspect(reason)}")
    end
  end
end
