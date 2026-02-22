%{
  priority: :critical,
  status: :draft,
  title: "Signals",
  repos: ["jido_signal", "jido"],
  tags: [:docs, :concepts, :core, :signals],
  audience: :intermediate,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/concepts/signals",
  ecosystem_packages: ["jido_signal", "jido"],
  learning_outcomes: ["Describe signal structure, metadata, and naming conventions",
   "Explain routing patterns and how signals map to actions",
   "Understand idempotency and duplicate-delivery considerations"],
  order: 40,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Document typed message envelopes and routing patterns that coordinate agent communication",
  related: ["docs/concepts/actions", "docs/concepts/agent-runtime",
   "docs/learn/signals-routing", "docs/reference/packages/jido-signal"],
  source_files: ["lib/jido/signal.ex", "lib/jido/signal/router.ex"],
  source_modules: ["Jido.Signal", "Jido.Signal.Router"],
  prompt_overrides: %{
    document_intent: "Write the authoritative guide to Jido Signals — typed message envelopes, routing, and coordination.",
    required_sections: ["Signal Structure", "Naming Conventions", "Routing Patterns", "Idempotency", "Signal Lifecycle"],
    must_include: ["Signal fields aligned with source definitions",
     "Naming taxonomy: intent signals vs fact signals",
     "Route tables mapping signal types to action modules",
     "Idempotency and duplicate-delivery considerations",
     "Signal metadata: identifiers, timestamps, source"],
    must_avoid: ["Duplicating tutorial content from Learn section",
     "Directive details — that's the directives page"],
    required_links: ["/docs/concepts/agents", "/docs/concepts/agent-runtime",
     "/docs/learn/signals-routing", "/docs/reference/packages/jido-signal"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Authoritative concept page for Jido Signals — typed message envelopes, routing patterns, and coordination.

Cover:
- Signal structure and metadata fields
- Naming conventions: intent vs fact signals
- Route tables mapping signals to actions
- Idempotency and duplicate delivery handling

### Validation Criteria

- Signal fields and helpers align with `Jido.Signal` source definitions
- Routing guidance reflects runtime behavior in AgentServer
- Includes idempotency and duplicate-delivery considerations
- Links to jido_signal package reference for API details
