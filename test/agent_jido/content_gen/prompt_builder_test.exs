defmodule AgentJido.ContentGen.PromptBuilderTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.PromptBuilder

  test "build/3 includes authoritative docs contract for docs concept pages" do
    entry =
      entry(%{
        id: "docs/agents",
        title: "Agents",
        body: "<h2>Content Brief</h2><p>Definitive guide.</p>",
        tags: [:hub_concepts, :format_markdown]
      })

    target = %{route: "/docs/concepts/agents", target_path: "priv/pages/docs/concepts/agents.md", format: :md}
    prompt = PromptBuilder.build(entry, target, %{update_mode: :improve, existing: nil})

    assert prompt =~ "principal documentation author"
    assert prompt =~ "Page profile"
    assert prompt =~ "docs_concept"
    assert prompt =~ "required_section_order"
    assert prompt =~ "Definition and Mental Model"
    assert prompt =~ "Progressive Examples"
    assert prompt =~ "minimum_code_blocks"
  end

  test "build/3 applies prompt_overrides from content-plan metadata" do
    entry =
      entry(%{
        prompt_overrides: %{
          "replace_required_sections" => true,
          "required_sections" => ["Custom Section"],
          "must_include" => ["Explain command semantics deeply"],
          "min_words" => 1200,
          "document_intent" => "Authoritative agent semantics page"
        }
      })

    target = %{route: "/docs/concepts/agents", target_path: "priv/pages/docs/concepts/agents.md", format: :md}
    prompt = PromptBuilder.build(entry, target, %{update_mode: :improve, existing: nil})

    [_, sections_block] = Regex.run(~r/required_section_order:\n(.*?)\n\nmust_include:/s, prompt)

    assert sections_block =~ "- Custom Section"
    refute sections_block =~ "- Definition and Mental Model"
    assert prompt =~ "Authoritative agent semantics page"
    assert prompt =~ "Explain command semantics deeply"
    assert prompt =~ "word_range: 1200-1800"
  end

  test "build/3 normalizes html brief content before including it in prompt" do
    entry =
      entry(%{
        body: """
        <h2>Content Brief</h2>
        <p>Define agents.</p>
        <ul><li>Use source modules</li><li>Include next steps</li></ul>
        """
      })

    target = %{route: "/docs/concepts/agents", target_path: "priv/pages/docs/concepts/agents.md", format: :md}
    prompt = PromptBuilder.build(entry, target, %{update_mode: :improve, existing: nil})

    assert prompt =~ "Content Brief"
    assert prompt =~ "- Use source modules"
    refute prompt =~ "<h2>"
    refute prompt =~ "<li>"
  end

  defp entry(attrs) do
    Map.merge(
      %{
        id: "docs/agents",
        title: "Agents",
        section: "docs",
        order: 60,
        status: :draft,
        purpose: "Define agents in Jido",
        audience: :intermediate,
        content_type: :guide,
        learning_outcomes: [],
        repos: [],
        source_modules: [],
        source_files: [],
        prerequisites: [],
        related: [],
        ecosystem_packages: [],
        destination_route: "/docs/concepts/agents",
        tags: [:hub_concepts, :format_markdown],
        prompt_overrides: %{},
        body: "Content brief"
      },
      attrs
    )
  end
end
