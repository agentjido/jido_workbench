%{
  priority: :high,
  status: :planned,
  title: "Package Reference: jido_behaviortree",
  repos: ["jido_behaviortree"],
  tags: [:docs, :reference, :packages, :jido_behaviortree, :behavior_tree, :workflows, :deterministic],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido-behaviortree",
  ecosystem_packages: ["jido_behaviortree"],
  learning_outcomes: [
    "Understand the purpose of the jido_behaviortree package",
    "Know how to install and configure jido_behaviortree",
    "Identify key modules for behavior tree definition and execution",
    "Understand how behavior trees enable deterministic agent workflows"
  ],
  order: 110,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido_behaviortree package covering behavior tree execution for deterministic agent workflows.",
  related: [
    "docs/learn/behavior-tree-without-llm",
    "docs/reference/packages/jido-runic",
    "docs/reference/packages/jido"
  ],
  source_modules: ["Jido.BehaviorTree"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido_behaviortree package — behavior tree execution for building deterministic, composable agent workflows.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet",
      "Summary of behavior tree node types, execution, and composition modules",
      "Configuration options",
      "Usage examples showing behavior tree definition and execution"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido_behaviortree",
      "GitHub repository",
      "docs/learn/behavior-tree-without-llm",
      "docs/reference/packages/jido-runic"
    ],
    min_words: 600,
    max_words: 1200,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference for the `jido_behaviortree` package — behavior tree execution for deterministic agent workflows in the Jido ecosystem. Covers behavior tree node types (sequence, selector, decorator, etc.), tree composition, execution semantics, and how behavior trees provide structured, predictable control flow for agents without requiring LLM calls. This package is ideal for agents that need reliable, repeatable decision-making.

### Validation Criteria

- Clearly explains the package's role in deterministic agent workflow execution
- Includes a working Mix dependency installation snippet
- Documents key modules for tree nodes, composition, and execution
- Lists configuration options
- Provides at least 3 code examples showing behavior tree definition and execution
- Links to the behavior tree tutorial and jido_runic package reference
- Does not duplicate full API docs from HexDocs
