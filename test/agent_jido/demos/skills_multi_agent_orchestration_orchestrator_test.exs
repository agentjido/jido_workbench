defmodule AgentJido.Demos.SkillsMultiAgentOrchestrationOrchestratorTest do
  use ExUnit.Case, async: false

  alias AgentJido.Demos.SkillsMultiAgentOrchestration.Orchestrator

  setup do
    demo = Orchestrator.new()

    on_exit(fn ->
      Orchestrator.reset(demo)
    end)

    %{demo: demo}
  end

  test "boots the specialist registry with module and file skills", %{demo: demo} do
    assert demo.loaded_count == 1

    assert Enum.map(demo.registry_specs, & &1.name) == [
             "demo-orchestrator-arithmetic",
             "demo-unit-converter",
             "demo-endurance-planner"
           ]
  end

  test "routes arithmetic requests to the arithmetic specialist", %{demo: demo} do
    demo = Orchestrator.run_scenario(demo, :arithmetic)

    assert demo.last_run.selected_skill_names == ["demo-orchestrator-arithmetic"]
    assert Enum.map(demo.last_run.tool_trace, & &1.tool) == ["multiply", "add"]
    assert demo.last_run.response =~ "814"
    assert demo.last_run.prompt =~ "demo-orchestrator-arithmetic"
  end

  test "routes conversion requests to the file-backed unit converter", %{demo: demo} do
    demo = Orchestrator.run_scenario(demo, :conversion)

    assert demo.last_run.selected_skill_names == ["demo-unit-converter"]
    assert Enum.map(demo.last_run.tool_trace, & &1.tool) == ["convert_temperature"]
    assert demo.last_run.response =~ "37.0"
    assert demo.last_run.prompt =~ "demo-unit-converter"
  end

  test "routes combined requests through conversion and endurance specialists", %{demo: demo} do
    demo = Orchestrator.run_scenario(demo, :combined)

    assert demo.last_run.selected_skill_names == ["demo-unit-converter", "demo-endurance-planner"]
    assert Enum.map(demo.last_run.tool_trace, & &1.tool) == ["convert_distance", "estimate_calories"]
    assert demo.last_run.response =~ "3.11 miles"
    assert demo.last_run.response =~ "311 calories"
    assert demo.last_run.prompt =~ "demo-endurance-planner"
  end
end
