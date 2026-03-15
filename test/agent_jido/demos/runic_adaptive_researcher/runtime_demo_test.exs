defmodule AgentJido.Demos.RunicAdaptiveResearcher.RuntimeDemoTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.RunicAdaptiveResearcher.RuntimeDemo

  test "rich topic selects the full adaptive branch" do
    demo =
      RuntimeDemo.new("incident-retro-rich")
      |> RuntimeDemo.run()

    assert demo.status == :success
    assert demo.phase_2_type == :full
    assert demo.selected_workflow == :phase_2_full
    assert demo.summary_length > 180
    assert demo.article_markdown =~ "## Research Sources"
    assert Enum.map(demo.phase_2_graph.nodes, & &1.name) == [:build_outline, :draft_article, :edit_and_assemble]
  end

  test "thin topic selects the slim adaptive branch" do
    demo =
      RuntimeDemo.new("release-brief-slim")
      |> RuntimeDemo.run()

    assert demo.status == :success
    assert demo.phase_2_type == :slim
    assert demo.selected_workflow == :phase_2_slim
    assert demo.summary_length < 180
    assert demo.article_markdown =~ "## Takeaway"
    assert Enum.map(demo.phase_2_graph.nodes, & &1.name) == [:draft_article, :edit_and_assemble]
  end
end
