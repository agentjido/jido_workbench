defmodule AgentJido.ContentGen.OrchestratorAgentTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentGen.OrchestratorAgent
  alias AgentJido.ContentGen.RunicEntryRunner

  test "build_workflow includes all expected content-gen action nodes" do
    workflow = OrchestratorAgent.build_workflow()

    assert workflow.name == :content_gen_entry_pipeline

    expected_nodes = [
      :build_entry_context,
      :resolve_target,
      :load_existing,
      :generate_structure_plan,
      :generate_draft_envelope,
      :parse_and_assemble_candidate,
      :audit_and_gate,
      :verify_if_requested,
      :persist_and_finalize
    ]

    assert Map.keys(workflow.components) |> Enum.sort() == Enum.sort(expected_nodes)
  end

  test "run_entry returns skipped status for non-file-backed routes" do
    entry = %{
      id: "features/root",
      title: "Features Root",
      section: "features",
      order: 1,
      status: :outline,
      destination_collection: :pages,
      destination_route: "/features",
      purpose: "Root features hub",
      audience: :beginner,
      content_type: :guide,
      learning_outcomes: [],
      repos: [],
      source_modules: [],
      source_files: [],
      prerequisites: [],
      related: [],
      ecosystem_packages: [],
      tags: [],
      prompt_overrides: %{}
    }

    run_opts = %{
      opts: %{
        apply: false,
        fail_on_audit: true,
        verify: false,
        docs_format: :tag,
        update_mode: :improve
      },
      apply?: false,
      fail_on_audit: true,
      verify?: false,
      docs_format: :tag,
      verifier: AgentJido.ContentGen.Verify,
      run_dir: "tmp/content_gen/runs/orchestrator_agent_test_#{System.unique_integer([:positive])}",
      page_index: %{},
      route_patterns: ["/features"],
      source_index: %{modules: MapSet.new(), exports: MapSet.new(), package_paths: %{}, scanned_files: 0}
    }

    assert {:ok, result} = RunicEntryRunner.run_entry(entry, run_opts)
    assert result.status == :skipped_non_file_target
  end
end
