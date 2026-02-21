defmodule AgentJido.ContentGen.Audit.ContentAuditorTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.Audit.ContentAuditor

  test "flags placeholders, unknown exports, broken links, and missing evidence" do
    entry = %{
      source_modules: ["Jido.Worker"],
      source_files: ["lib/jido/worker.ex"]
    }

    target = %{route: "/docs/reference/example"}

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
  end

  test "passes when references and cross-links are valid" do
    entry = %{
      source_modules: ["Jido.Worker"],
      source_files: ["lib/jido/worker.ex"]
    }

    target = %{route: "/docs/reference/example"}

    candidate = %{
      body_markdown: """
      Use `Jido.Worker.run/1` for execution.
      Source file: `lib/jido/worker.ex`.
      Next steps: [Build quickstart](/build/quickstarts-by-persona).
      """,
      raw: """
      Use `Jido.Worker.run/1` for execution.
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

    assert audit.errors == []
    assert audit.score > 0.9
  end

  test "does not flag example-local modules as unknown exports" do
    entry = %{
      source_modules: ["Jido.Worker"],
      source_files: ["lib/jido/worker.ex"]
    }

    target = %{route: "/docs/reference/example"}

    candidate = %{
      body_markdown: """
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
    entry = %{source_modules: [], source_files: []}
    target = %{route: "/docs/reference/example"}

    candidate = %{
      body_markdown: """
      Strategy.init/2 can be called from the wrapper.
      Next steps: [Build quickstart](/build/quickstarts-by-persona).
      """,
      raw: """
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
end
