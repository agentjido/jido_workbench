defmodule AgentJido.ContentGen.Audit.ContentAuditorTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.Audit.ContentAuditor

  test "flags placeholders, unknown exports, broken links, and missing evidence" do
    entry = %{
      section: "docs",
      source_modules: ["Jido.Worker"],
      source_files: ["lib/jido/worker.ex"],
      prompt_overrides: relaxed_contract_overrides()
    }

    target = %{route: "/docs/reference/example", format: :md}

    candidate = %{
      body_markdown: """
      TODO: fill this in.
      See Missing.Module.run/1.
      Link [broken](/not-a-real-route).
      """,
      raw: """
      TODO: fill this in.
      """
    }

    source_index = %{
      modules: MapSet.new(["Jido.Worker"]),
      exports: MapSet.new([{"Jido.Worker", "run", 1}])
    }

    audit =
      ContentAuditor.audit(entry, target, candidate,
        source_index: source_index,
        route_patterns: ["/docs/:slug", "/build/:slug"]
      )

    codes = Enum.map(audit.errors, & &1.code)

    assert :placeholder_detected in codes
    assert :unknown_module_export in codes
    assert :missing_source_module_mention in codes
    assert :missing_source_file_citation in codes
    assert :broken_internal_link in codes
    assert :contract_missing_required_section in codes
  end

  test "passes when references and cross-links are valid" do
    entry = %{
      section: "docs",
      source_modules: ["Jido.Worker"],
      source_files: ["lib/jido/worker.ex"],
      prompt_overrides: relaxed_contract_overrides()
    }

    target = %{route: "/docs/reference/example", format: :md}

    candidate = %{
      body_markdown: """
      ## Overview

      Use `Jido.Worker.run/1` for execution.
      Docs hub: [Docs](/docs/reference).
      Source file: `lib/jido/worker.ex`.
      ```elixir
      Jido.Worker.run(:ok)
      ```
      Next steps: [Build quickstart](/build/quickstarts-by-persona).
      """,
      raw: """
      ## Overview

      Use `Jido.Worker.run/1` for execution.
      Docs hub: [Docs](/docs/reference).
      Source file: `lib/jido/worker.ex`.
      ```elixir
      Jido.Worker.run(:ok)
      ```
      Next steps: [Build quickstart](/build/quickstarts-by-persona).
      """
    }

    source_index = %{
      modules: MapSet.new(["Jido.Worker"]),
      exports: MapSet.new([{"Jido.Worker", "run", 1}])
    }

    audit =
      ContentAuditor.audit(entry, target, candidate,
        source_index: source_index,
        route_patterns: ["/docs/:slug", "/build/:slug"]
      )

    assert audit.errors == []
    assert audit.score > 0.9
  end

  test "accepts planned internal links that are not yet in route patterns" do
    entry = %{
      section: "build",
      source_modules: ["AgentJido.Application"],
      source_files: ["config/runtime.exs"],
      prompt_overrides: relaxed_contract_overrides()
    }

    target = %{route: "/build/installation", format: :md}

    candidate = %{
      body_markdown: """
      ## Overview

      Setup details live here.
      Next: [Build Your First Agent](/build/first-agent)
      Source file: `config/runtime.exs`.
      """,
      raw: """
      ## Overview

      Setup details live here.
      Next: [Build Your First Agent](/build/first-agent)
      Source file: `config/runtime.exs`.
      """
    }

    source_index = %{modules: MapSet.new(["AgentJido.Application"]), exports: MapSet.new()}

    audit =
      ContentAuditor.audit(entry, target, candidate,
        source_index: source_index,
        route_patterns: ["/build", "/docs"],
        planned_routes: ["/build/first-agent"]
      )

    refute Enum.any?(audit.errors, &(&1.code == :broken_internal_link))
  end

  test "does not flag example-local modules as unknown exports" do
    entry = %{
      section: "docs",
      source_modules: ["Jido.Worker"],
      source_files: ["lib/jido/worker.ex"],
      prompt_overrides: relaxed_contract_overrides()
    }

    target = %{route: "/docs/reference/example", format: :md}

    candidate = %{
      body_markdown: """
      ## Overview

      ```elixir
      defmodule MyApp.WorkerAgent do
        def run(input), do: input
      end

      agent = MyApp.WorkerAgent.new/1
      MyApp.WorkerAgent.cmd/2
      ```

      Source file: `lib/jido/worker.ex`.
      Next steps: [Build quickstart](/build/quickstarts-by-persona).
      Jido module call: `Jido.Worker.run/1`.
      """,
      raw: """
      ## Overview

      Source file: `lib/jido/worker.ex`.
      Next steps: [Build quickstart](/build/quickstarts-by-persona).
      """
    }

    source_index = %{
      modules: MapSet.new(["Jido.Worker"]),
      exports: MapSet.new([{"Jido.Worker", "run", 1}])
    }

    audit =
      ContentAuditor.audit(entry, target, candidate,
        source_index: source_index,
        route_patterns: ["/docs/:slug", "/build/:slug"]
      )

    refute Enum.any?(audit.errors, &(&1.code == :unknown_module_export))
  end

  test "ignores alias-style references without full module path" do
    entry = %{section: "docs", source_modules: [], source_files: [], prompt_overrides: relaxed_contract_overrides()}
    target = %{route: "/docs/reference/example", format: :md}

    candidate = %{
      body_markdown: """
      ## Overview

      Strategy.init/2 can be called from the wrapper.
      Next steps: [Build quickstart](/build/quickstarts-by-persona).
      """,
      raw: """
      ## Overview

      Strategy.init/2 can be called from the wrapper.
      Next steps: [Build quickstart](/build/quickstarts-by-persona).
      """
    }

    source_index = %{modules: MapSet.new(), exports: MapSet.new()}

    audit =
      ContentAuditor.audit(entry, target, candidate,
        source_index: source_index,
        route_patterns: ["/docs/:slug", "/build/:slug"]
      )

    refute Enum.any?(audit.errors, &(&1.code == :unknown_module_export))
  end

  defp relaxed_contract_overrides do
    %{
      "replace_required_sections" => true,
      "required_sections" => ["Overview"],
      "required_links" => ["/build/quickstarts-by-persona"],
      "min_words" => 1,
      "max_words" => 3_000,
      "minimum_code_blocks" => 0,
      "minimum_fun_refs" => 0
    }
  end
end
