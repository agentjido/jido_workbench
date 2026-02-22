defmodule AgentJido.ContentGen.RunTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentGen.Run
  alias AgentJido.Pages.LivebookParser

  defmodule TestBackend do
    @behaviour AgentJido.ContentGen.Backends.Backend

    def generate_object(_prompt, _opts) do
      {:ok,
       %{
         object: %{
           section_order: ["Overview"],
           section_briefs: "Overview: explain usage and constraints.",
           citation_plan: ["Jido.Worker.run/1"],
           consistency_rules: ["Short paragraphs", "Concrete examples"]
         },
         meta: %{backend: :test, mode: :structured_object}
       }}
    end

    @impl true
    def generate(_prompt, _opts) do
      envelope = %{
        frontmatter: %{
          "title" => "Generated Title",
          "description" => "Generated description"
        },
        body_markdown: """
        ## Overview

        Use `Jido.Worker.run/1` for execution.

        ```elixir
        Jido.Worker.run(%{})
        ```

        Link to docs: [Docs Hub](/docs)
        Link to build: [Build Quickstarts](/build/quickstarts-by-persona)
        """,
        citations: ["Jido.Worker"],
        audit_notes: ["synthetic test payload"]
      }

      {:ok, %{text: Jason.encode!(envelope), meta: %{backend: :test}}}
    end
  end

  defmodule MarkdownFallbackBackend do
    @behaviour AgentJido.ContentGen.Backends.Backend

    def generate_object(_prompt, _opts) do
      {:ok,
       %{
         object: %{
           section_order: ["Overview"],
           section_briefs: "Overview: execute one runnable example."
         },
         meta: %{backend: :fallback, mode: :structured_object}
       }}
    end

    @impl true
    def generate(_prompt, _opts) do
      {:ok,
       %{
         text: """
         ## Overview

         Use `Jido.Worker.run/1` for execution.

         ```elixir
         Jido.Worker.run(:ok)
         ```

         Link to docs: [Docs Hub](/docs)
         Link to build: [Build Quickstarts](/build/quickstarts-by-persona)
         """,
         meta: %{backend: :fallback}
       }}
    end
  end

  defmodule PassingVerifier do
    def verify(_entry, _target, _candidate, _audit, _opts) do
      %{
        status: "passed",
        checks: ["audit_only", "route_render", "livebook_test"],
        check_results: %{audit_only: "passed", route_render: "passed", livebook_test: "passed"},
        livebook_test_file: "test/livebooks/docs/concepts_agents_livebook_test.exs",
        command_output_excerpt: nil
      }
    end
  end

  test "dry-run creates report and candidate artifacts without writing target file" do
    tmp_dir = tmp_dir!("content_gen_run_dry")
    route = "/docs/unit-test-dry-run"
    target_path = repo_target_path!("unit-test-dry-run.md")
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
    target_path = repo_target_path!("unit-test-apply.md")
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
        backend: :req_llm,
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

  test "strict parse gate rejects markdown fallback when apply is enabled" do
    tmp_dir = tmp_dir!("content_gen_run_strict_parse")
    route = "/docs/unit-test-strict-parse"
    target_path = repo_target_path!("unit-test-strict-parse.md")
    report_path = Path.join(tmp_dir, "report.json")

    opts =
      run_opts(
        route,
        target_path,
        %{
          apply: true,
          run_id: "strict_parse_#{System.unique_integer([:positive])}",
          report: report_path,
          backend_modules: %{codex: MarkdownFallbackBackend, req_llm: MarkdownFallbackBackend}
        }
      )

    assert {:error, report} = Run.run(opts)
    [entry] = report.entries
    assert entry.status == :parse_failed
    assert entry.reason =~ "strict mode requires JSON envelope output"
    refute File.exists?(target_path)
  end

  test "markdown fallback can proceed in dry-run when strict mode is off" do
    tmp_dir = tmp_dir!("content_gen_run_fallback_dry")
    route = "/docs/unit-test-fallback-dry"
    target_path = repo_target_path!("unit-test-fallback-dry.md")
    report_path = Path.join(tmp_dir, "report.json")

    opts =
      run_opts(
        route,
        target_path,
        %{
          apply: false,
          run_id: "fallback_dry_#{System.unique_integer([:positive])}",
          report: report_path,
          backend_modules: %{codex: MarkdownFallbackBackend, req_llm: MarkdownFallbackBackend}
        }
      )

    assert {:ok, report} = Run.run(opts)
    [entry] = report.entries
    assert entry.status == :dry_run_candidate
    assert entry.parse_mode == :fallback_markdown
  end

  test "verify metadata is attached when verifier passes" do
    tmp_dir = tmp_dir!("content_gen_run_verify")
    route = "/docs/unit-test-verify"
    target_path = repo_target_path!("unit-test-verify.md")
    report_path = Path.join(tmp_dir, "report.json")

    opts =
      run_opts(
        route,
        target_path,
        %{
          apply: true,
          verify: true,
          docs_format: :tag,
          verifier: PassingVerifier,
          run_id: "verify_#{System.unique_integer([:positive])}",
          report: report_path
        }
      )

    assert {:ok, report} = Run.run(opts)
    [entry] = report.entries
    assert entry.status == :written
    assert entry.verification.status == "passed"
    assert entry.verification.check_results.livebook_test == "passed"
    assert entry.verification.livebook_test_file =~ "_livebook_test.exs"
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
        backend: :req_llm,
        update_mode: :improve,
        fail_on_audit: true,
        verify: false,
        docs_format: :tag,
        backend_modules: %{codex: TestBackend, req_llm: TestBackend},
        source_index: source_index(),
        route_patterns: ["/docs", "/docs/:slug", "/build/:slug", "/training/:slug", "/ecosystem/:slug"],
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
        tags: [:format_markdown],
        prompt_overrides: %{
          "replace_required_sections" => true,
          "required_sections" => ["Overview"],
          "required_links" => ["/build/quickstarts-by-persona"],
          "min_words" => 1,
          "max_words" => 2_000,
          "minimum_code_blocks" => 0,
          "minimum_fun_refs" => 0
        }
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

  defp repo_target_path!(filename) do
    unique_name = "#{System.unique_integer([:positive])}_#{filename}"
    path = Path.join(["priv", "pages", "tmp_content_gen_test", unique_name])
    :ok = File.mkdir_p(Path.dirname(path))

    on_exit(fn ->
      File.rm(path)
      File.rm(String.replace_suffix(path, ".md", ".livemd"))
    end)

    path
  end
end
