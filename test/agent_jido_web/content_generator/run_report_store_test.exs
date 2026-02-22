defmodule AgentJidoWeb.ContentGenerator.RunReportStoreTest do
  use ExUnit.Case, async: true

  alias AgentJidoWeb.ContentGenerator.RunReportStore

  test "loads reports, sorts newest first, and indexes latest entry status" do
    runs_root = tmp_runs_root!("run_report_store")

    write_report!(runs_root, "run_old", "docs/concepts/agents", "2026-02-20T10:00:00Z", "failed")
    write_report!(runs_root, "run_new", "docs/concepts/agents", "2026-02-21T11:00:00Z", "passed")

    store = RunReportStore.load(runs_root: runs_root)

    assert [first | _] = store.runs
    assert first.run_id == "run_new"
    assert store.warnings == []

    latest_entry = RunReportStore.latest_entry(store, "docs/concepts/agents")
    assert latest_entry.run_id == "run_new"
    assert latest_entry.verification.status == "passed"

    run = RunReportStore.get_run(store, "run_old")
    assert run.status == :failed
  end

  test "skips corrupt report files with warning" do
    runs_root = tmp_runs_root!("run_report_store_corrupt")

    run_dir = Path.join(runs_root, "run_bad")
    :ok = File.mkdir_p(run_dir)
    :ok = File.write(Path.join(run_dir, "report.json"), "{not valid json")

    store = RunReportStore.load(runs_root: runs_root)

    assert store.runs == []
    assert length(store.warnings) == 1
    assert hd(store.warnings) =~ "Skipping invalid run report"
  end

  defp write_report!(runs_root, run_id, entry_id, generated_at, verification_status) do
    run_dir = Path.join(runs_root, run_id)
    report_path = Path.join(run_dir, "report.json")
    candidate_path = Path.join([run_dir, "candidates", String.replace(entry_id, "/", "__") <> ".livemd"])

    :ok = File.mkdir_p(Path.dirname(candidate_path))
    :ok = File.write(candidate_path, "# candidate")

    report = %{
      run_id: run_id,
      generated_at: generated_at,
      report_path: report_path,
      run_dir: run_dir,
      options: %{
        apply: true,
        entry: entry_id,
        max: 1,
        statuses: ["draft"],
        sections: ["docs"],
        backend: "auto",
        model: nil,
        update_mode: "improve",
        source_root: "..",
        report: nil,
        fail_on_audit: true,
        verify: true,
        docs_format: "livemd"
      },
      stats: %{
        selected: 1,
        written: 1,
        dry_run_candidates: 0,
        skipped_noop: 0,
        skipped_non_file_target: 0,
        skipped_missing_for_audit: 0,
        audit_only_passed: 0,
        audit_failed: 0,
        generation_failed: if(verification_status == "failed", do: 1, else: 0),
        parse_failed: 0,
        churn_blocked: 0,
        verification_failed: if(verification_status == "failed", do: 1, else: 0)
      },
      entries: [
        %{
          id: entry_id,
          title: "Entry",
          section: "docs",
          route: "/docs/concepts/agents",
          status: "written",
          candidate_path: candidate_path,
          audit: %{errors: [], warnings: [], summary: %{}, score: 1.0},
          diff: %{changed: true, old_bytes: 0, new_bytes: 1, delta_bytes: 1, old_lines: 0, new_lines: 1, delta_lines: 1},
          verification: %{
            status: verification_status,
            checks: ["audit_only", "route_render", "livebook_test"],
            check_results: %{audit_only: "passed", route_render: "passed", livebook_test: verification_status},
            livebook_test_file: nil,
            command_output_excerpt: nil
          }
        }
      ],
      change_requests: []
    }

    :ok = File.mkdir_p(run_dir)
    :ok = File.write(report_path, Jason.encode!(report))
  end

  defp tmp_runs_root!(prefix) do
    path = Path.join(System.tmp_dir!(), "#{prefix}_#{System.unique_integer([:positive])}")
    :ok = File.mkdir_p(path)

    on_exit(fn ->
      File.rm_rf(path)
    end)

    path
  end
end
