defmodule AgentJidoWeb.ContentGenerator.EntryStatusTest do
  use ExUnit.Case, async: true

  alias AgentJidoWeb.ContentGenerator.EntryStatus

  test "derives missing artifact status with unknown verify status" do
    tmp_dir = tmp_dir!("entry_status_missing")
    plan_path = Path.join(tmp_dir, "entry.md")
    :ok = File.write(plan_path, "plan")

    entry =
      entry_fixture(%{
        path: plan_path,
        destination_route: "/docs/entry-status-missing"
      })

    status =
      EntryStatus.derive(
        entry,
        nil,
        page_index: %{"/docs/entry-status-missing" => Path.join(tmp_dir, "missing.livemd")},
        docs_format: :tag
      )

    assert status.artifact_status == :missing
    assert status.verify_status == :unknown
  end

  test "derives generated status and passed verification" do
    tmp_dir = tmp_dir!("entry_status_generated")
    plan_path = Path.join(tmp_dir, "entry.md")
    artifact_path = Path.join(tmp_dir, "generated.livemd")
    base_mtime = System.os_time(:second)

    :ok = File.write(plan_path, "plan")
    :ok = File.write(artifact_path, "artifact")
    :ok = File.touch(plan_path, base_mtime)
    :ok = File.touch(artifact_path, base_mtime + 2)

    latest = %{
      run_id: "run_ok",
      generated_at: DateTime.utc_now(),
      verification: %{status: "passed"}
    }

    entry =
      entry_fixture(%{
        path: plan_path,
        destination_route: "/docs/entry-status-generated"
      })

    status =
      EntryStatus.derive(
        entry,
        latest,
        page_index: %{"/docs/entry-status-generated" => artifact_path},
        docs_format: :tag
      )

    assert status.artifact_status == :generated
    assert status.verify_status == :passed
    assert status.entry_health == :healthy
    assert status.last_run_id == "run_ok"
  end

  test "derives stale artifact when plan is newer" do
    tmp_dir = tmp_dir!("entry_status_stale")
    plan_path = Path.join(tmp_dir, "entry.md")
    artifact_path = Path.join(tmp_dir, "stale.livemd")
    base_mtime = System.os_time(:second)

    :ok = File.write(artifact_path, "artifact")
    :ok = File.write(plan_path, "plan")
    :ok = File.touch(artifact_path, base_mtime)
    :ok = File.touch(plan_path, base_mtime + 2)

    latest = %{
      run_id: "run_bad",
      generated_at: DateTime.utc_now(),
      verification: %{status: "failed"}
    }

    entry =
      entry_fixture(%{
        path: plan_path,
        destination_route: "/docs/entry-status-stale"
      })

    status =
      EntryStatus.derive(
        entry,
        latest,
        page_index: %{"/docs/entry-status-stale" => artifact_path},
        docs_format: :tag
      )

    assert status.artifact_status == :stale
    assert status.verify_status == :failed
    assert status.entry_health == :critical
  end

  defp entry_fixture(overrides) do
    Map.merge(
      %{
        id: "docs/entry-status",
        section: "docs",
        destination_route: "/docs/entry-status",
        tags: [],
        path: ""
      },
      overrides
    )
  end

  defp tmp_dir!(prefix) do
    path = Path.join(System.tmp_dir!(), "#{prefix}_#{System.unique_integer([:positive])}")
    :ok = File.mkdir_p(path)

    on_exit(fn ->
      File.rm_rf(path)
    end)

    path
  end
end
