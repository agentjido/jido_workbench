%{
  priority: :critical,
  status: :planned,
  title: "Package Reference: jido_runic",
  repos: ["jido_runic"],
  tags: [:docs, :reference, :packages, :jido_runic, :rules, :decisions, :logic],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido-runic",
  ecosystem_packages: ["jido_runic"],
  learning_outcomes: [
    "Understand the purpose of the jido_runic package",
    "Know how to install and configure jido_runic",
    "Identify key modules for rule definition and evaluation",
    "Understand how jido_runic enables deterministic decision logic in agents"
  ],
  order: 60,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido_runic package covering rule engine and decision logic for agents.",
  related: [
    "docs/concepts/agents",
    "docs/learn/behavior-tree-without-llm",
    "docs/reference/packages/jido",
    "docs/reference/packages/jido-behaviortree"
  ],
  source_modules: ["Jido.Runic"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido_runic package — a rule engine and decision logic library for deterministic agent behavior.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet",
      "Summary of rule definition, evaluation, and composition modules",
      "Configuration options",
      "Usage examples showing rule definition and decision evaluation"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido_runic",
      "GitHub repository",
      "docs/concepts/agents",
      "docs/learn/behavior-tree-without-llm"
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

Reference for the `jido_runic` package — a rule engine and decision logic library for the Jido ecosystem. Covers how to define rules, evaluate conditions, and compose decision trees that enable deterministic agent behavior without requiring LLM calls. This package is essential for building agents that follow structured, predictable decision paths.

### Validation Criteria

- Clearly explains the package's role as a rule engine for deterministic decisions
- Includes a working Mix dependency installation snippet
- Documents key modules for rule definition and evaluation
- Lists configuration options
- Provides at least 3 code examples showing rule definition and evaluation
- Links to agent concepts and behavior tree tutorial
- Does not duplicate full API docs from HexDocs
