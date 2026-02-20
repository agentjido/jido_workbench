defmodule Mix.Tasks.Site.LinkAuditTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    Mix.Task.reenable("site.link_audit")

    report_path =
      Path.join(System.tmp_dir!(), "site_link_audit_test_#{System.unique_integer([:positive])}.md")

    on_exit(fn ->
      Mix.Task.reenable("site.link_audit")
      File.rm(report_path)
    end)

    {:ok, report_path: report_path}
  end

  test "runs and writes a report when configured for launch hidden routes", %{report_path: report_path} do
    output =
      capture_io(fn ->
        Mix.Tasks.Site.LinkAudit.run([
          "--include-heex",
          "--allow-prefix",
          "/training",
          "--report",
          report_path
        ])
      end)

    assert output =~ "Route patterns checked"
    assert output =~ "Internal links checked"
    assert output =~ "Unmatched internal links: 0"
    assert output =~ "Report written:"

    assert File.exists?(report_path)
    assert File.read!(report_path) =~ "# Link Audit Report"
  end

  test "raises for invalid options" do
    assert_raise Mix.Error, ~r/Invalid options/, fn ->
      capture_io(fn ->
        Mix.Tasks.Site.LinkAudit.run(["--does-not-exist"])
      end)
    end
  end
end
