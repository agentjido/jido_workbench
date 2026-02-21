defmodule AgentJido.ContentGen.RunTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentGen.Run
  alias AgentJido.Pages.LivebookParser

  defmodule TestBackend do
    @behaviour AgentJido.ContentGen.Backends.Backend

    @impl true
    def generate(_prompt, _opts) do
      envelope = %{
        frontmatter: %{
          "title" => "Generated Title",
          "description" => "Generated description"
        },
        body_markdown: """
        # Generated

        Link to build: [Build Quickstarts](/build/quickstarts-by-persona)
        """,
        citations: ["Jido.Worker"],
        audit_notes: ["synthetic test payload"]
      }

      {:ok, %{text: Jason.encode!(envelope), meta: %{backend: :test}}}
    end
  end

  test "dry-run creates report and candidate artifacts without writing target file" do
    tmp_dir = tmp_dir!("content_gen_run_dry")
    route = "/docs/unit-test-dry-run"
    target_path = Path.join(tmp_dir, "unit-test-dry-run.md")
    report_path = Path.join(tmp_dir, "report.json")

    opts =
      run_opts(
        route,
        target_path,
        %{
          apply: false,
          run_id: "dry_#{System.unique_integer([:positive])}",
          report: report_path
        }
      )

    assert {:ok, report} = Run.run(opts)
    assert File.exists?(report_path)
    refute File.exists?(target_path)

    assert report.stats.selected == 1
    assert report.stats.dry_run_candidates == 1

    [entry] = report.entries
    assert entry.status == :dry_run_candidate
    assert is_binary(entry.candidate_path)
    assert File.exists?(entry.candidate_path)
  end

  test "apply writes valid page content to target path" do
    tmp_dir = tmp_dir!("content_gen_run_apply")
    route = "/docs/unit-test-apply"
    target_path = Path.join(tmp_dir, "unit-test-apply.md")
    report_path = Path.join(tmp_dir, "report.json")

    opts =
      run_opts(
        route,
        target_path,
        %{
          apply: true,
          run_id: "apply_#{System.unique_integer([:positive])}",
          report: report_path
        }
      )

    assert {:ok, report} = Run.run(opts)
    assert report.stats.written == 1
    assert File.exists?(target_path)

    raw = File.read!(target_path)
    {frontmatter, body} = LivebookParser.parse(target_path, raw)
    assert frontmatter[:title] == "Generated Title"
    assert body =~ "Build Quickstarts"
  end

  test "non-file-backed routes are skipped and reported" do
    tmp_dir = tmp_dir!("content_gen_run_skip")
    report_path = Path.join(tmp_dir, "report.json")

    entry =
      entry(%{
        id: "features/root",
        section: "features",
        destination_route: "/features"
      })

    opts =
      %{
        entries: [entry],
        apply: false,
        max: 10,
        statuses: [:outline],
        run_id: "skip_#{System.unique_integer([:positive])}",
        report: report_path,
        backend: :codex,
        backend_modules: %{codex: TestBackend, req_llm: TestBackend},
        source_index: source_index(),
        route_patterns: ["/docs/:slug", "/build/:slug"],
        page_index: %{}
      }

    assert {:ok, report} = Run.run(opts)
    assert report.stats.skipped_non_file_target == 1

    [entry_result] = report.entries
    assert entry_result.status == :skipped_non_file_target
  end

  defp run_opts(route, target_path, overrides) do
    entry =
      entry(%{
        id: "docs/#{route |> String.trim_leading("/") |> String.replace("/", "-")}",
        destination_route: route
      })

    Map.merge(
      %{
        entries: [entry],
        apply: false,
        max: 10,
        statuses: [:outline],
        backend: :codex,
        update_mode: :improve,
        fail_on_audit: true,
        backend_modules: %{codex: TestBackend, req_llm: TestBackend},
        source_index: source_index(),
        route_patterns: ["/docs/:slug", "/build/:slug", "/training/:slug", "/ecosystem/:slug"],
        page_index: %{route => target_path}
      },
      overrides
    )
  end

  defp source_index do
    %{
      modules: MapSet.new(["Jido.Worker"]),
      exports: MapSet.new([{"Jido.Worker", "run", 1}]),
      package_paths: %{},
      scanned_files: 0
    }
  end

  defp entry(attrs) do
    Map.merge(
      %{
        id: "docs/test",
        title: "Test Entry",
        section: "docs",
        order: 100,
        status: :outline,
        destination_collection: :pages,
        destination_route: "/docs/test",
        purpose: "Generate test docs content",
        audience: :intermediate,
        content_type: :guide,
        learning_outcomes: [],
        repos: [],
        source_modules: [],
        source_files: [],
        prerequisites: [],
        related: [],
        ecosystem_packages: [],
        tags: [:format_markdown]
      },
      attrs
    )
  end

  defp tmp_dir!(prefix) do
    path = Path.join(System.tmp_dir!(), "#{prefix}_#{System.unique_integer([:positive])}")
    :ok = File.mkdir_p(path)
    on_exit(fn -> File.rm_rf(path) end)
    path
  end
end
