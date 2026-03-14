defmodule AgentJido.Demos.RunicResearchStudio.RuntimeDemoTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.RunicResearchStudio.RuntimeDemo

  test "run_auto completes the deterministic pipeline and produces an article" do
    demo =
      RuntimeDemo.new(:auto)
      |> RuntimeDemo.run_auto()

    assert demo.execution_mode == :auto
    assert demo.status == :success
    assert length(demo.executions) == 5
    assert demo.productions != []
    assert demo.article_title == "Elixir Concurrency"
    assert demo.article_markdown =~ "## Research Sources"
    assert Enum.all?(demo.graph.nodes, &(&1.status == :completed))
  end

  test "prepare_step, step, and resume use real held-runnable transitions" do
    demo =
      RuntimeDemo.new(:step)
      |> RuntimeDemo.prepare_step()

    assert demo.execution_mode == :step
    assert demo.status == :paused
    assert demo.held_nodes == [:plan_queries]
    assert demo.executions == []

    demo = RuntimeDemo.step(demo)

    assert demo.status == :paused
    assert length(demo.executions) == 1
    assert length(demo.step_history) == 1
    assert demo.held_nodes == [:simulate_search]

    demo = RuntimeDemo.resume(demo)

    assert demo.execution_mode == :auto
    assert demo.status == :success
    assert length(demo.executions) == 5
    assert demo.article_markdown =~ "## Takeaway"
  end
end
