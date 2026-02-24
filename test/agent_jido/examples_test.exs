defmodule AgentJido.ExamplesTest do
  use ExUnit.Case, async: true

  alias AgentJido.Examples

  @hidden_slug "budget-guardrail-agent"

  test "unpublished examples are hidden from default lookups" do
    assert is_nil(Examples.get_example(@hidden_slug))
    assert_raise AgentJido.Examples.NotFoundError, fn -> Examples.get_example!(@hidden_slug) end

    refute Enum.any?(Examples.all_examples(), &(&1.slug == @hidden_slug))
    assert Enum.any?(Examples.all_examples(include_unpublished: true), &(&1.slug == @hidden_slug))
  end

  test "include_unpublished opt-in exposes hidden examples" do
    example = Examples.get_example!(@hidden_slug, include_unpublished: true)

    assert example.slug == @hidden_slug
    assert example.published == false
  end
end
