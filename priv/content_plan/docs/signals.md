%{
  priority: :high,
  status: :draft,
  title: "Signals",
  repos: ["jido_signal", "jido"],
  tags: [:docs, :core, :signals, :coordination, :hub_concepts, :format_livebook, :wave_1],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/concepts/signals",
  ecosystem_packages: ["jido_signal", "jido"],
  learning_outcomes: ["Create stable signal contracts", "Route signals without over-coupling producers and consumers",
   "Use metadata for traceability and debugging"],
  order: 80,
  prerequisites: ["docs/key-concepts"],
  purpose: "Document typed message envelopes and routing patterns for inter-agent coordination",
  related: ["docs/actions", "docs/agent-server", "training/signals-routing", "build/multi-agent-workflows"],
  source_files: ["lib/jido/signal.ex"],
  source_modules: ["Jido.Signal"]
}
---
## Content Brief

Signal structure, metadata, routing, and practical coordination guidance.

### Validation Criteria

- Signal fields and helpers align with source definitions
- Routing guidance reflects runtime behavior in AgentServer
- Includes idempotency and duplicate-delivery considerations
