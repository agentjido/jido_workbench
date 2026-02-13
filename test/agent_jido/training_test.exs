defmodule AgentJido.TrainingTest do
  use ExUnit.Case, async: true

  alias AgentJido.Training

  @expected_slugs [
    "agent-fundamentals",
    "actions-validation",
    "signals-routing",
    "directives-scheduling",
    "liveview-integration",
    "production-readiness"
  ]

  test "loads modules from markdown and keeps curriculum order" do
    modules = Training.all_modules()

    assert Training.module_count() == 6
    assert Enum.map(modules, & &1.slug) == @expected_slugs
    assert Enum.map(modules, & &1.order) == Enum.sort(Enum.map(modules, & &1.order))
  end

  test "looks up modules by slug" do
    module = Training.get_module!("directives-scheduling")

    assert module.title == "Directives, Scheduling, and Time-Based Behavior"
    assert Training.get_module("does-not-exist") == nil

    assert_raise Training.NotFoundError, fn ->
      Training.get_module!("does-not-exist")
    end
  end

  test "returns neighbors for middle and boundary modules" do
    {previous_module, next_module} = Training.neighbors("directives-scheduling")

    assert previous_module.slug == "signals-routing"
    assert next_module.slug == "liveview-integration"

    {first_previous, first_next} = Training.neighbors("agent-fundamentals")
    assert first_previous == nil
    assert first_next.slug == "actions-validation"
  end
end
