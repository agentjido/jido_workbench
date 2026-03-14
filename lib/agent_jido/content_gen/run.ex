defmodule AgentJido.ContentGen.Run do
  @moduledoc """
  Coordinates report scaffolding/selection and delegates per-entry execution to
  the Runic content generation orchestrator.
  """

  alias AgentJido.ContentGen
  alias AgentJido.ContentGen.Audit.SourceIndex
  alias AgentJido.ContentGen.PathResolver
  alias AgentJido.ContentGen.Report
  alias AgentJido.ContentGen.RunicEntryRunner
  alias AgentJido.ContentGen.Selection
  alias AgentJido.ContentGen.Verify
  alias AgentJido.ContentPlan
  alias AgentJido.Release.LinkAudit

  @type run_result :: {:ok, map()} | {:error, map()}

  @spec run(map()) :: run_result()
  def run(opts \\ %{}) when is_map(opts) do
    run_id = get_opt(opts, :run_id, default_run_id())
    run_dir = ContentGen.run_dir(run_id)
    report_path = get_opt(opts, :report, Path.join(run_dir, "report.json"))
    source_root = get_opt(opts, :source_root, "..")
    apply? = get_opt(opts, :apply, false)
    fail_on_audit = get_opt(opts, :fail_on_audit, true)
    verify? = get_opt(opts, :verify, false)
    docs_format = get_opt(opts, :docs_format, :tag)
    verifier = get_opt(opts, :verifier, Verify)
    entry_runner = get_opt(opts, :entry_runner, RunicEntryRunner)

    :ok = File.mkdir_p(Path.join(run_dir, "candidates"))

    entries = get_opt(opts, :entries, ContentPlan.all_entries())
    selected = Selection.select(opts, entries)
    page_index = get_opt(opts, :page_index, PathResolver.page_index())
    route_patterns = get_opt(opts, :route_patterns, LinkAudit.route_patterns())
    planned_routes = get_opt(opts, :planned_routes, planned_routes(entries))
    source_index = get_opt(opts, :source_index, SourceIndex.build(source_root: source_root))

    run_opts = %{
      opts: opts,
      apply?: apply?,
      fail_on_audit: fail_on_audit,
      verify?: verify?,
      docs_format: docs_format,
      verifier: verifier,
      run_dir: run_dir,
      page_index: page_index,
      route_patterns: route_patterns,
      planned_routes: planned_routes,
      source_index: source_index
    }

    report =
      Report.new(run_id, opts)
      |> Report.put_selected(length(selected))
      |> Map.put(:run_dir, run_dir)
      |> Map.put(:report_path, report_path)
      |> Map.put(:source_index_summary, source_index_summary(source_index))
      |> run_selected_entries(selected, run_opts, entry_runner)
      |> Report.finalize()

    case Report.write(report, report_path) do
      :ok ->
        if blocking_failures?(report, apply?, fail_on_audit) do
          {:error, report}
        else
          {:ok, report}
        end

      {:error, reason} ->
        {:error, Map.put(report, :report_write_error, reason)}
    end
  end

  defp run_selected_entries(report, selected, run_opts, entry_runner) do
    Enum.reduce(selected, report, fn entry, acc ->
      entry_result =
        case entry_runner.run_entry(entry, run_opts) do
          {:ok, result} -> normalize_entry_result(entry, result, run_opts)
          {:error, reason} -> generation_failure(entry, reason, run_opts)
        end

      Report.add_entry(acc, entry_result)
    end)
  end

  defp normalize_entry_result(entry, result, run_opts) when is_map(result) do
    result
    |> Map.put_new(:id, entry.id)
    |> Map.put_new(:title, entry.title)
    |> Map.put_new(:section, entry.section)
    |> Map.put_new(:order, entry.order)
    |> Map.put_new(:update_mode, Map.get(run_opts.opts, :update_mode, :improve))
    |> Map.update(:verification, default_verification(), &normalize_verification/1)
    |> Map.update(:workflow_step_failures, [], &List.wrap/1)
  end

  defp generation_failure(entry, reason, run_opts) do
    %{
      id: entry.id,
      title: entry.title,
      section: entry.section,
      order: entry.order,
      route: entry.destination_route,
      target_path: nil,
      read_path: nil,
      conversion_source_path: nil,
      format: nil,
      existed_before: false,
      update_mode: Map.get(run_opts.opts, :update_mode, :improve),
      verification: default_verification(),
      status: :generation_failed,
      reason: normalize_reason(reason),
      workflow_step_failures: []
    }
  end

  defp normalize_verification(verification) when is_map(verification), do: verification
  defp normalize_verification(_), do: default_verification()

  defp default_verification do
    %{
      status: "skipped",
      checks: [],
      check_results: %{},
      livebook_test_file: nil,
      command_output_excerpt: nil
    }
  end

  defp source_index_summary(source_index) do
    %{
      package_paths: Map.get(source_index, :package_paths, %{}),
      scanned_files: Map.get(source_index, :scanned_files, 0),
      module_count: source_index |> Map.get(:modules, MapSet.new()) |> MapSet.size(),
      export_count: source_index |> Map.get(:exports, MapSet.new()) |> MapSet.size()
    }
  end

  defp blocking_failures?(report, apply?, fail_on_audit) do
    stats = report.stats || %{}
    counts = failure_counts(stats)

    counts.generation_or_parse_failed? or
      (apply? and fail_on_audit and counts.audit_failed?) or
      counts.verification_failed?
  end

  defp failure_counts(stats) do
    %{
      generation_or_parse_failed?: (stats.generation_failed || 0) > 0 or (stats.parse_failed || 0) > 0,
      audit_failed?: (stats.audit_failed || 0) > 0,
      verification_failed?: (stats.verification_failed || 0) > 0
    }
  end

  defp default_run_id do
    ts = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_unix()
    "run_#{ts}_#{System.unique_integer([:positive])}"
  end

  defp get_opt(opts, key, default) do
    case Map.get(opts, key) do
      nil -> default
      value -> value
    end
  end

  defp planned_routes(entries) do
    entries
    |> Enum.filter(&(&1.destination_collection == :pages))
    |> Enum.map(&normalize_route(&1.destination_route))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp normalize_route(route) when is_binary(route) do
    route
    |> String.trim()
    |> String.replace(~r/[?#].*$/, "")
    |> case do
      "" -> nil
      "/" -> "/"
      value -> String.trim_trailing(value, "/")
    end
  end

  defp normalize_route(_), do: nil

  defp normalize_reason(%{__exception__: true} = error), do: Exception.message(error)
  defp normalize_reason(reason) when is_binary(reason), do: reason
  defp normalize_reason(reason) when is_atom(reason), do: Atom.to_string(reason)
  defp normalize_reason(reason), do: inspect(reason)
end
