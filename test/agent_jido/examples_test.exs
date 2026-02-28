defmodule AgentJido.ExamplesTest do
  use ExUnit.Case, async: true

  alias AgentJido.Examples

  @hidden_slug "budget-guardrail-agent"
  @simulated_slug "browser-agent"

  test "draft examples are hidden from default lookups" do
    assert is_nil(Examples.get_example(@hidden_slug))
    assert_raise AgentJido.Examples.NotFoundError, fn -> Examples.get_example!(@hidden_slug) end

    refute Enum.any?(Examples.all_examples(), &(&1.slug == @hidden_slug))
    assert Enum.any?(Examples.all_examples(include_unpublished: true), &(&1.slug == @hidden_slug))
  end

  test "include_unpublished opt-in exposes draft examples" do
    example = Examples.get_example!(@hidden_slug, include_unpublished: true)

    assert example.slug == @hidden_slug
    assert example.status == :draft
    assert example.published == false
  end

  test "taxonomy filters can narrow visible examples" do
    filtered =
      Examples.all_examples(
        scenario_cluster: :coordination,
        capability_theme: :coordination_orchestration
      )

    assert Enum.any?(filtered, &(&1.slug == "workflow-coordinator"))
    refute Enum.any?(filtered, &(&1.slug == @simulated_slug))
  end

  test "simulated showcase examples are visible and tagged with simulated demo mode" do
    example = Examples.get_example!(@simulated_slug)

    assert example.status == :live
    assert example.demo_mode == :simulated
    assert example.scenario_cluster == :ai_tool_use
    assert example.capability_theme == :ai_intelligence
  end
end
