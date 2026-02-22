defmodule AgentJidoWeb.ContentGenerator.RunReportStore do
  @moduledoc """
  Loads and normalizes content-generation run reports from `tmp/content_gen/runs/*/report.json`.
  """

  @default_runs_root Path.join(["tmp", "content_gen", "runs"])

  @type store :: %{
          runs: [map()],
          by_run_id: %{optional(String.t()) => map()},
          latest_by_entry: %{optional(String.t()) => map()},
          warnings: [String.t()],
          runs_root: String.t()
        }

  @spec empty() :: store()
  def empty do
    %{
      runs: [],
      by_run_id: %{},
      latest_by_entry: %{},
      warnings: [],
      runs_root: @default_runs_root
    }
  end

  @spec load(keyword()) :: store()
  def load(opts \\ []) do
    runs_root = Keyword.get(opts, :runs_root, @default_runs_root)
    limit = Keyword.get(opts, :limit, 200)

    report_paths = Path.wildcard(Path.join([runs_root, "*", "report.json"]))

    {runs, warnings} =
      Enum.reduce(report_paths, {[], []}, fn report_path, {run_acc, warning_acc} ->
        case load_report(report_path) do
          {:ok, run} -> {[run | run_acc], warning_acc}
          {:error, warning} -> {run_acc, [warning | warning_acc]}
        end
      end)

    runs =
      runs
      |> Enum.sort_by(&sort_key/1, :desc)
      |> Enum.take(limit)

    %{
      runs: runs,
      by_run_id: Map.new(runs, &{&1.run_id, &1}),
      latest_by_entry: latest_entry_index(runs),
      warnings: Enum.reverse(warnings),
      runs_root: runs_root
    }
  end

  @spec get_run(store(), String.t()) :: map() | nil
  def get_run(%{by_run_id: by_run_id}, run_id) when is_binary(run_id), do: Map.get(by_run_id, run_id)
  def get_run(_store, _run_id), do: nil

  @spec latest_entry(store(), String.t()) :: map() | nil
  def latest_entry(%{latest_by_entry: latest_by_entry}, entry_id) when is_binary(entry_id), do: Map.get(latest_by_entry, entry_id)
  def latest_entry(_store, _entry_id), do: nil

  defp load_report(path) do
    with {:ok, raw} <- File.read(path),
         {:ok, decoded} <- Jason.decode(raw) do
      {:ok, normalize_run(decoded, path)}
    else
      {:error, reason} ->
        {:error, "Skipping invalid run report #{path}: #{inspect(reason)}"}
    end
  rescue
    error ->
      {:error, "Skipping invalid run report #{path}: #{Exception.message(error)}"}
  end

  defp normalize_run(decoded, report_path) do
    generated_at = parse_datetime(fetch(decoded, "generated_at")) || file_mtime(report_path)
    options = normalize_options(fetch(decoded, "options", %{}))
    stats = normalize_stats(fetch(decoded, "stats", %{}))
    run_id = fetch(decoded, "run_id") || run_id_from_report_path(report_path)

    entries =
      decoded
      |> fetch("entries", [])
      |> List.wrap()
      |> Enum.map(&normalize_entry/1)

    %{
      run_id: to_string(run_id),
      generated_at: generated_at,
      report_path: fetch(decoded, "report_path") || report_path,
      run_dir: fetch(decoded, "run_dir") || Path.dirname(report_path),
      options: options,
      status: run_status(stats, options),
      stats: stats,
      entries: entries,
      source_index_summary: fetch(decoded, "source_index_summary", %{}),
      change_requests: fetch(decoded, "change_requests", [])
    }
  end

  defp normalize_options(raw_options) when is_map(raw_options) do
    %{
      apply: truthy?(fetch(raw_options, "apply", false)),
      entry: blank_to_nil(fetch(raw_options, "entry")),
      max: normalize_integer(fetch(raw_options, "max"), 10),
      report: blank_to_nil(fetch(raw_options, "report")),
      statuses: normalize_string_list(fetch(raw_options, "statuses", [])),
      sections: normalize_string_list(fetch(raw_options, "sections", [])),
      backend: normalize_atom_or_string(fetch(raw_options, "backend", "auto")),
      model: blank_to_nil(fetch(raw_options, "model")),
      update_mode: normalize_atom_or_string(fetch(raw_options, "update_mode", "improve")),
      source_root: blank_to_nil(fetch(raw_options, "source_root")),
      fail_on_audit: truthy?(fetch(raw_options, "fail_on_audit", true)),
      verify: truthy?(fetch(raw_options, "verify", false)),
      docs_format: normalize_atom_or_string(fetch(raw_options, "docs_format", "tag"))
    }
  end

  defp normalize_options(_raw_options) do
    %{
      apply: false,
      entry: nil,
      max: 10,
      report: nil,
      statuses: [],
      sections: [],
      backend: "auto",
      model: nil,
      update_mode: "improve",
      source_root: nil,
      fail_on_audit: true,
      verify: false,
      docs_format: "tag"
    }
  end

  defp normalize_stats(raw_stats) when is_map(raw_stats) do
    %{
      selected: normalize_integer(fetch(raw_stats, "selected"), 0),
      written: normalize_integer(fetch(raw_stats, "written"), 0),
      dry_run_candidates: normalize_integer(fetch(raw_stats, "dry_run_candidates"), 0),
      skipped_noop: normalize_integer(fetch(raw_stats, "skipped_noop"), 0),
      skipped_non_file_target: normalize_integer(fetch(raw_stats, "skipped_non_file_target"), 0),
      skipped_missing_for_audit: normalize_integer(fetch(raw_stats, "skipped_missing_for_audit"), 0),
      audit_only_passed: normalize_integer(fetch(raw_stats, "audit_only_passed"), 0),
      audit_failed: normalize_integer(fetch(raw_stats, "audit_failed"), 0),
      generation_failed: normalize_integer(fetch(raw_stats, "generation_failed"), 0),
      parse_failed: normalize_integer(fetch(raw_stats, "parse_failed"), 0),
      churn_blocked: normalize_integer(fetch(raw_stats, "churn_blocked"), 0),
      verification_failed: normalize_integer(fetch(raw_stats, "verification_failed"), 0)
    }
  end

  defp normalize_stats(_raw_stats) do
    %{
      selected: 0,
      written: 0,
      dry_run_candidates: 0,
      skipped_noop: 0,
      skipped_non_file_target: 0,
      skipped_missing_for_audit: 0,
      audit_only_passed: 0,
      audit_failed: 0,
      generation_failed: 0,
      parse_failed: 0,
      churn_blocked: 0,
      verification_failed: 0
    }
  end

  defp normalize_entry(raw_entry) when is_map(raw_entry) do
    verification = normalize_verification(fetch(raw_entry, "verification", %{}))

    %{
      id: blank_to_nil(fetch(raw_entry, "id")),
      title: blank_to_nil(fetch(raw_entry, "title")),
      section: blank_to_nil(fetch(raw_entry, "section")),
      route: blank_to_nil(fetch(raw_entry, "route")),
      status: normalize_status(fetch(raw_entry, "status", "unknown")),
      reason: blank_to_nil(fetch(raw_entry, "reason")),
      target_path: blank_to_nil(fetch(raw_entry, "target_path")),
      read_path: blank_to_nil(fetch(raw_entry, "read_path")),
      candidate_path: blank_to_nil(fetch(raw_entry, "candidate_path")),
      format: normalize_atom_or_string(fetch(raw_entry, "format")),
      parse_mode: normalize_atom_or_string(fetch(raw_entry, "parse_mode")),
      existed_before: truthy?(fetch(raw_entry, "existed_before", false)),
      audit: normalize_audit(fetch(raw_entry, "audit", %{})),
      diff: normalize_diff(fetch(raw_entry, "diff", %{})),
      verification: verification,
      update_mode: normalize_atom_or_string(fetch(raw_entry, "update_mode")),
      backend: normalize_atom_or_string(fetch(raw_entry, "backend")),
      model: blank_to_nil(fetch(raw_entry, "model")),
      content_hash: blank_to_nil(fetch(raw_entry, "content_hash"))
    }
  end

  defp normalize_entry(_raw_entry), do: %{}

  defp normalize_audit(raw_audit) when is_map(raw_audit) do
    %{
      errors: normalize_map_list(fetch(raw_audit, "errors", [])),
      warnings: normalize_map_list(fetch(raw_audit, "warnings", [])),
      summary: fetch(raw_audit, "summary", %{}),
      score: fetch(raw_audit, "score")
    }
  end

  defp normalize_audit(_raw_audit), do: %{errors: [], warnings: [], summary: %{}, score: nil}

  defp normalize_diff(raw_diff) when is_map(raw_diff) do
    %{
      changed: truthy?(fetch(raw_diff, "changed", false)),
      old_bytes: normalize_integer(fetch(raw_diff, "old_bytes"), 0),
      new_bytes: normalize_integer(fetch(raw_diff, "new_bytes"), 0),
      delta_bytes: normalize_integer(fetch(raw_diff, "delta_bytes"), 0),
      old_lines: normalize_integer(fetch(raw_diff, "old_lines"), 0),
      new_lines: normalize_integer(fetch(raw_diff, "new_lines"), 0),
      delta_lines: normalize_integer(fetch(raw_diff, "delta_lines"), 0)
    }
  end

  defp normalize_diff(_raw_diff) do
    %{
      changed: false,
      old_bytes: 0,
      new_bytes: 0,
      delta_bytes: 0,
      old_lines: 0,
      new_lines: 0,
      delta_lines: 0
    }
  end

  defp normalize_verification(raw_verification) when is_map(raw_verification) do
    check_results =
      raw_verification
      |> fetch("check_results", %{})
      |> normalize_check_results()

    %{
      status: normalize_verification_status(fetch(raw_verification, "status")),
      checks: normalize_string_list(fetch(raw_verification, "checks", [])),
      check_results: check_results,
      livebook_test_file: blank_to_nil(fetch(raw_verification, "livebook_test_file")),
      command_output_excerpt: blank_to_nil(fetch(raw_verification, "command_output_excerpt"))
    }
  end

  defp normalize_verification(_raw_verification) do
    %{
      status: "unknown",
      checks: [],
      check_results: %{},
      livebook_test_file: nil,
      command_output_excerpt: nil
    }
  end

  defp normalize_check_results(results) when is_map(results) do
    Enum.reduce(results, %{}, fn {key, value}, acc ->
      normalized_key =
        key
        |> to_string()
        |> String.trim()
        |> String.downcase()

      Map.put(acc, normalized_key, to_string(value))
    end)
  end

  defp normalize_check_results(_results), do: %{}

  defp normalize_map_list(values) when is_list(values) do
    Enum.map(values, fn
      %{} = map -> map
      value -> %{message: to_string(value)}
    end)
  end

  defp normalize_map_list(_values), do: []

  defp run_status(stats, options) do
    cond do
      stats.generation_failed > 0 or stats.parse_failed > 0 or stats.verification_failed > 0 ->
        :failed

      stats.audit_failed > 0 and options.apply and options.fail_on_audit ->
        :failed

      true ->
        :completed
    end
  end

  defp latest_entry_index(runs) do
    Enum.reduce(runs, %{}, fn run, acc ->
      Enum.reduce(run.entries, acc, fn entry, entry_acc ->
        case entry.id do
          id when is_binary(id) and id != "" ->
            Map.put_new(entry_acc, id, Map.merge(entry, %{run_id: run.run_id, generated_at: run.generated_at, run_status: run.status}))

          _other ->
            entry_acc
        end
      end)
    end)
  end

  defp sort_key(run) do
    dt = run.generated_at || ~U[1970-01-01 00:00:00Z]
    DateTime.to_unix(dt, :second)
  end

  defp run_id_from_report_path(path) do
    path
    |> Path.dirname()
    |> Path.basename()
  end

  defp parse_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} -> datetime
      _other -> nil
    end
  end

  defp parse_datetime(_value), do: nil

  defp file_mtime(path) when is_binary(path) do
    case File.stat(path, time: :posix) do
      {:ok, stat} -> DateTime.from_unix!(stat.mtime)
      {:error, _reason} -> nil
    end
  end

  defp file_mtime(_path), do: nil

  defp normalize_status(value) when is_atom(value), do: value

  defp normalize_status(value) when is_binary(value) do
    case value |> String.trim() |> String.downcase() do
      "written" -> :written
      "dry_run_candidate" -> :dry_run_candidate
      "skipped_noop" -> :skipped_noop
      "skipped_non_file_target" -> :skipped_non_file_target
      "skipped_missing_for_audit" -> :skipped_missing_for_audit
      "audit_only_passed" -> :audit_only_passed
      "audit_failed" -> :audit_failed
      "generation_failed" -> :generation_failed
      "parse_failed" -> :parse_failed
      "churn_blocked" -> :churn_blocked
      "verification_failed" -> :verification_failed
      _other -> :unknown
    end
  end

  defp normalize_status(_value), do: :unknown

  defp normalize_verification_status(value) when is_binary(value) do
    case String.downcase(String.trim(value)) do
      "passed" -> "passed"
      "failed" -> "failed"
      "skipped" -> "skipped"
      _other -> "unknown"
    end
  end

  defp normalize_verification_status(_value), do: "unknown"

  defp normalize_string_list(values) when is_list(values) do
    values
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_string_list(value) when is_binary(value), do: normalize_string_list([value])
  defp normalize_string_list(_value), do: []

  defp normalize_atom_or_string(nil), do: nil
  defp normalize_atom_or_string(value) when is_atom(value), do: Atom.to_string(value)

  defp normalize_atom_or_string(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_atom_or_string(value), do: to_string(value)

  defp normalize_integer(value, _default) when is_integer(value), do: value

  defp normalize_integer(value, _default) when is_float(value), do: trunc(value)

  defp normalize_integer(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _other -> default
    end
  end

  defp normalize_integer(_value, default), do: default

  defp blank_to_nil(nil), do: nil

  defp blank_to_nil(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp blank_to_nil(value), do: to_string(value)

  defp truthy?(value), do: value in [true, "true", "1", 1, "on"]

  defp fetch(map, key, default \\ nil)

  defp fetch(map, key, default) when is_map(map) and is_binary(key) do
    case Map.fetch(map, key) do
      {:ok, value} ->
        value

      :error ->
        atom_key = String.to_existing_atom(key)
        Map.get(map, atom_key, default)
    end
  rescue
    ArgumentError ->
      default
  end

  defp fetch(_map, _key, default), do: default
end
