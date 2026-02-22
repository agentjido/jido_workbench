%{
  priority: :critical,
  status: :outline,
  title: "Package Reference: jido_signal",
  repos: ["jido_signal"],
  tags: [:docs, :reference, :packages, :jido_signal, :signals, :routing, :events],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido-signal",
  ecosystem_packages: ["jido_signal"],
  learning_outcomes: [
    "Understand the purpose of the jido_signal package",
    "Know how to install and configure jido_signal",
    "Identify key modules for signal definition and routing",
    "Understand signal lifecycle and dispatch patterns"
  ],
  order: 30,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido_signal package covering signal definition, routing, and dispatch.",
  related: [
    "docs/concepts/signals",
    "docs/reference/packages/jido"
  ],
  source_modules: ["Jido.Signal"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido_signal package — the signal definition and routing library for the Jido ecosystem.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet",
      "Summary of signal definition, routing, and dispatch modules",
      "Configuration options",
      "Usage examples showing signal creation and routing"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido_signal",
      "GitHub repository",
      "docs/concepts/signals"
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

Reference for the `jido_signal` package — the signal definition and routing library within the Jido ecosystem. Covers how to define signals, configure routing rules, and dispatch signals to agents. Signals are the primary communication mechanism between agents and the outside world, enabling event-driven architectures.

### Validation Criteria

- Clearly explains the package's role in signal definition and routing
- Includes a working Mix dependency installation snippet
- Documents key modules for signal creation, routing, and dispatch
- Lists configuration options
- Provides at least 3 code examples showing signal definition and routing
- Links to the signals concept page and core jido package reference
- Does not duplicate full API docs from HexDocs
