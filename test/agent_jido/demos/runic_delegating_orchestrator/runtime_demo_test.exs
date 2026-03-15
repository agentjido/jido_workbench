defmodule AgentJido.Demos.RunicDelegatingOrchestrator.RuntimeDemoTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.RunicDelegatingOrchestrator.RuntimeDemo

  test "run completes the delegating pipeline with local and child-worker stages" do
    demo =
      RuntimeDemo.new("elixir-concurrency")
      |> RuntimeDemo.run()

    assert demo.status == :success
    assert RuntimeDemo.completed_local_nodes(demo) == [:plan_queries, :simulate_search, :build_outline]
    assert RuntimeDemo.completed_child_tags(demo) == [:drafter, :editor]
    assert Enum.map(demo.graph.nodes, & &1.status) == [:completed, :completed, :completed, :completed, :completed]
    assert demo.article_markdown =~ "## Research Sources"
    assert demo.takeaway =~ "Concurrency pays off"
  end

  test "handoff history records spawn, child start, and completion for each delegated node" do
    demo =
      RuntimeDemo.new("fly-bluegreen")
      |> RuntimeDemo.run()

    assert Enum.count(demo.handoffs, &(&1.state == :spawn_requested)) == 2
    assert Enum.count(demo.handoffs, &(&1.state == :child_started)) == 2
    assert Enum.count(demo.handoffs, &(&1.state == :completed)) == 2
    assert Enum.any?(demo.handoffs, &(&1.tag == :drafter and &1.node == :draft_article))
    assert Enum.any?(demo.handoffs, &(&1.tag == :editor and &1.node == :edit_and_assemble))
  end
end
