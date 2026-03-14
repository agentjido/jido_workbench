defmodule Mix.Tasks.Content.Plan.GenerateTest do
  use ExUnit.Case, async: false

  @moduletag :slow

  import ExUnit.CaptureIO
  alias Mix.Tasks.Content.Plan.Generate

  setup do
    Mix.Task.reenable("content.plan.generate")

    report_path =
      Path.join(System.tmp_dir!(), "content_plan_generate_test_#{System.unique_integer([:positive])}.json")

    on_exit(fn ->
      Mix.Task.reenable("content.plan.generate")
      File.rm(report_path)
    end)

    {:ok, report_path: report_path}
  end

  test "runs in audit_only mode for a single entry and writes a report", %{report_path: report_path} do
    output =
      capture_io(fn ->
        Generate.run([
          "--entry",
          "docs/getting-started",
          "--update-mode",
          "audit_only",
          "--max",
          "1",
          "--report",
          report_path
        ])
      end)

    assert output =~ "Run ID:"
    assert output =~ "Report:"
    assert File.exists?(report_path)
  end

  test "raises for invalid options" do
    assert_raise Mix.Error, ~r/Invalid options/, fn ->
      capture_io(fn ->
        Generate.run(["--definitely-invalid"])
      end)
    end
  end

  test "rejects --model flag" do
    assert_raise Mix.Error, ~r/Invalid options/, fn ->
      capture_io(fn ->
        Generate.run(["--model", "anthropic:claude-sonnet-4.6"])
      end)
    end
  end

  test "--verify requires --entry" do
    assert_raise Mix.Error, ~r/--verify requires --entry docs\/<id>/, fn ->
      capture_io(fn ->
        Generate.run(["--verify"])
      end)
    end
  end

  test "--verify rejects non-docs entries" do
    assert_raise Mix.Error, ~r/--verify is docs-only/, fn ->
      capture_io(fn ->
        Generate.run([
          "--entry",
          "features/overview",
          "--verify"
        ])
      end)
    end
  end

  test "defaults docs format to livemd for docs entry", %{report_path: report_path} do
    capture_io(fn ->
      Generate.run([
        "--entry",
        "docs/getting-started",
        "--update-mode",
        "audit_only",
        "--max",
        "1",
        "--report",
        report_path
      ])
    end)

    report =
      report_path
      |> File.read!()
      |> Jason.decode!()

    assert report["options"]["docs_format"] == "livemd"
  end
end
