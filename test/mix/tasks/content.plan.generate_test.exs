defmodule Mix.Tasks.Content.Plan.GenerateTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

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
        Mix.Tasks.Content.Plan.Generate.run([
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
        Mix.Tasks.Content.Plan.Generate.run(["--definitely-invalid"])
      end)
    end
  end
end
