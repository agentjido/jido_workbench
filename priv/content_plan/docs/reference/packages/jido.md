%{
  priority: :critical,
  status: :outline,
  title: "Package Reference: jido",
  repos: ["jido"],
  tags: [:docs, :reference, :packages, :jido, :core, :agents, :actions, :runtime],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido",
  ecosystem_packages: ["jido"],
  learning_outcomes: [
    "Understand the purpose and scope of the jido core package",
    "Know how to install and configure jido",
    "Identify key modules and their responsibilities",
    "Understand how jido relates to other ecosystem packages"
  ],
  order: 10,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido core framework package including agents, actions, directives, and runtime.",
  related: [
    "docs/concepts/agents",
    "docs/concepts/actions",
    "docs/concepts/signals",
    "docs/concepts/key-concepts",
    "docs/reference/packages/jido-action",
    "docs/reference/packages/jido-signal",
    "docs/reference/packages/jido-ai"
  ],
  source_modules: ["Jido.Agent", "Jido.Action", "Jido.Signal", "Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido core package — the foundational framework for building AI agents with Elixir.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet",
      "Summary of core modules: Agent, Action, Signal, AgentServer",
      "Configuration options and defaults",
      "Basic usage examples showing agent definition and action execution"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido",
      "GitHub repository",
      "docs/concepts/agents",
      "docs/concepts/actions",
      "docs/concepts/signals"
    ],
    min_words: 800,
    max_words: 1500,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Comprehensive reference for the `jido` core package — the foundational framework for building AI agents in Elixir. Covers the package's purpose as the central hub of the Jido ecosystem, installation, key modules (Agent, Action, Signal, AgentServer), configuration options, and basic usage examples. This page serves as the primary entry point for developers exploring the Jido package ecosystem.

### Validation Criteria

- Clearly explains what the jido package provides and its role as the core framework
- Includes a working Mix dependency installation snippet
- Documents all key modules with a brief description of each
- Lists configuration options with defaults
- Provides at least 3 code examples showing basic agent and action usage
- Links to relevant concept pages and other package references
- Does not duplicate full API docs from HexDocs
