defmodule AgentJido.ContentGen.Report do
  @moduledoc """
  Run report helpers for content generation.
  """

  @spec new(String.t(), map()) :: map()
  def new(run_id, opts) do
    %{
      run_id: run_id,
      generated_at: DateTime.utc_now(),
      options: sanitize_opts(opts),
      entries: [],
      stats: %{
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
        churn_blocked: 0
      },
      change_requests: []
    }
  end

  @spec put_selected(map(), non_neg_integer()) :: map()
  def put_selected(report, count), do: put_in(report, [:stats, :selected], count)

  @spec add_entry(map(), map()) :: map()
  def add_entry(report, entry_result) do
    report
    |> update_in([:entries], &(&1 ++ [entry_result]))
    |> accumulate_stats(entry_result)
    |> accumulate_change_requests(entry_result)
  end

  @spec finalize(map()) :: map()
  def finalize(report), do: report

  @spec write(map(), String.t()) :: :ok | {:error, String.t()}
  def write(report, path) do
    with :ok <- File.mkdir_p(Path.dirname(path)),
         {:ok, json} <- Jason.encode(report, pretty: true),
         :ok <- File.write(path, json) do
      :ok
    else
      {:error, reason} -> {:error, "failed to write report #{path}: #{inspect(reason)}"}
    end
  end

  defp sanitize_opts(opts) do
    opts
    |> Map.take([
      :apply,
      :max,
      :sections,
      :entry,
      :statuses,
      :backend,
      :model,
      :update_mode,
      :source_root,
      :report,
      :fail_on_audit
    ])
  end

  defp accumulate_stats(report, %{status: status}) do
    key =
      case status do
        :written -> :written
        :dry_run_candidate -> :dry_run_candidates
        :skipped_noop -> :skipped_noop
        :skipped_non_file_target -> :skipped_non_file_target
        :skipped_missing_for_audit -> :skipped_missing_for_audit
        :audit_only_passed -> :audit_only_passed
        :audit_failed -> :audit_failed
        :generation_failed -> :generation_failed
        :parse_failed -> :parse_failed
        :churn_blocked -> :churn_blocked
        _other -> nil
      end

    if key do
      update_in(report, [:stats, key], &(&1 + 1))
    else
      report
    end
  end

  defp accumulate_change_requests(report, %{status: status, target_path: target_path, content_hash: content_hash} = entry_result)
       when status in [:written, :dry_run_candidate] do
    change_request = %{
      id: entry_result.id,
      route: entry_result.route,
      target_path: target_path,
      op: if(status == :written, do: :update, else: :proposed_update),
      content_hash: content_hash
    }

    update_in(report, [:change_requests], &(&1 ++ [change_request]))
  end

  defp accumulate_change_requests(report, _entry_result), do: report
end
