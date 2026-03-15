defmodule AgentJido.Demos.RunicStructuredBranching.RuntimeDemoTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.RunicStructuredBranching.RuntimeDemo

  test "analysis prompt selects the analysis branch and runs the two-node phase-2 workflow" do
    demo =
      RuntimeDemo.new("release-risk")
      |> RuntimeDemo.run()

    assert demo.status == :success
    assert demo.selected_branch == :analysis
    assert demo.selected_workflow == :phase_2_analysis
    assert demo.decision.detail_level == :detailed
    assert demo.branch_result =~ "investigate for 10 minutes"
    assert Enum.map(demo.phase_2_graph.nodes, & &1.name) == [:analysis_plan, :analysis_answer]
  end

  test "direct prompt selects the direct branch" do
    demo =
      RuntimeDemo.new("deps-command")
      |> RuntimeDemo.run()

    assert demo.status == :success
    assert demo.selected_branch == :direct
    assert demo.selected_workflow == :phase_2_direct
    assert demo.branch_result =~ "mix deps"
    assert Enum.map(demo.phase_2_graph.nodes, & &1.name) == [:direct_answer]
  end

  test "safety prompt selects the safe branch" do
    demo =
      RuntimeDemo.new("medical-safety")
      |> RuntimeDemo.run()

    assert demo.status == :success
    assert demo.selected_branch == :safe
    assert demo.selected_workflow == :phase_2_safe
    assert demo.branch_result =~ "seek urgent medical care"
    assert Enum.map(demo.phase_2_graph.nodes, & &1.name) == [:safe_response]
  end
end
