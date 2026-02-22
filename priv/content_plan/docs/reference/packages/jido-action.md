%{
  priority: :critical,
  status: :outline,
  title: "Package Reference: jido_action",
  repos: ["jido_action"],
  tags: [:docs, :reference, :packages, :jido_action, :actions, :composition],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido-action",
  ecosystem_packages: ["jido_action"],
  learning_outcomes: [
    "Understand the purpose of the jido_action package",
    "Know how to install and configure jido_action",
    "Identify key modules for defining and composing actions",
    "Understand action lifecycle and composition patterns"
  ],
  order: 20,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido_action package covering action definition, validation, and composition.",
  related: [
    "docs/concepts/actions",
    "docs/reference/packages/jido"
  ],
  source_modules: ["Jido.Action"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido_action package — the action definition and composition library for the Jido ecosystem.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet",
      "Summary of action definition, validation, and composition modules",
      "Configuration options",
      "Usage examples showing action definition and composition"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido_action",
      "GitHub repository",
      "docs/concepts/actions"
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

Reference for the `jido_action` package — the action definition and composition library within the Jido ecosystem. Covers how to define actions with schemas and validation, compose actions into pipelines, and handle action results. This package provides the building blocks that agents use to perform discrete units of work.

### Validation Criteria

- Clearly explains the package's role in action definition and composition
- Includes a working Mix dependency installation snippet
- Documents key modules for defining, validating, and composing actions
- Lists configuration options
- Provides at least 3 code examples showing action definition and composition
- Links to the actions concept page and core jido package reference
- Does not duplicate full API docs from HexDocs
