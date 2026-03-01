defmodule AgentJido.ExamplesTest do
  use ExUnit.Case, async: true

  alias AgentJido.Examples

  @hidden_slug "budget-guardrail-agent"
  @live_slug "counter-agent"

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
    filtered = Examples.all_examples(category: :core)

    assert Enum.any?(filtered, &(&1.slug == "counter-agent"))
    assert Enum.any?(filtered, &(&1.slug == "demand-tracker-agent"))
    assert Enum.any?(filtered, &(&1.slug == "address-normalization-agent"))
    refute Enum.any?(filtered, &(&1.slug == @hidden_slug))
  end

  test "selected live examples remain visible by default" do
    example = Examples.get_example!(@live_slug)

    assert example.status == :live
    assert example.demo_mode == :real
  end

  test "examples expose related resources metadata from frontmatter" do
    example = Examples.get_example!(@live_slug)

    assert is_list(example.related_resources)

    assert Enum.any?(example.related_resources, fn resource ->
             Map.get(resource, :path) == "/docs/getting-started/first-agent"
           end)
  end
end
