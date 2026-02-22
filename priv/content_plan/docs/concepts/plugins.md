%{
  priority: :high,
  status: :outline,
  title: "Plugins",
  repos: ["jido"],
  tags: [:docs, :concepts, :core, :plugins, :extensibility],
  audience: :intermediate,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/concepts/plugins",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Explain the plugin attachment model and lifecycle hooks",
   "Describe how plugins extend agent behavior without modifying core logic",
   "Know when to use plugins vs actions vs middleware"],
  order: 70,
  prerequisites: ["docs/concepts/agents", "docs/concepts/actions"],
  purpose: "Document the plugin primitive — composable behavior extensions that attach to agents without modifying core logic",
  related: ["docs/concepts/agents", "docs/concepts/agent-runtime",
   "docs/learn/agent-fundamentals"],
  source_modules: ["Jido.Agent"],
  prompt_overrides: %{
    document_intent: "Write the authoritative concept page for Jido Plugins — composable behavior extensions for agents.",
    required_sections: ["What Is a Plugin?", "Attachment Model", "Lifecycle Hooks", "Plugins vs Actions vs Middleware", "Building a Plugin"],
    must_include: ["Plugin attachment to agents via `use Jido.Agent`",
     "Lifecycle hooks and when they fire",
     "How plugins compose without conflicting",
     "Decision guide: when to use plugins vs actions"],
    must_avoid: ["Reimplementing agent concept content",
     "Exhaustive API reference — link to package reference"],
    required_links: ["/docs/concepts/agents", "/docs/concepts/agent-runtime",
     "/docs/learn/agent-fundamentals"],
    min_words: 400,
    max_words: 900,
    minimum_code_blocks: 2,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Authoritative concept page for Jido Plugins — composable behavior extensions that attach to agents without modifying core logic.

Cover:
- Plugin attachment model
- Lifecycle hooks and firing order
- Plugin composition without conflict
- Decision guide: plugins vs actions vs middleware

### Validation Criteria

- Plugin model aligns with `Jido.Agent` plugin implementation
- Lifecycle hooks are accurately described
- Decision guide provides clear criteria for choosing plugins
- Accessible to developers who have read the agents concept page
