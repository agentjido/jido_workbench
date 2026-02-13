%{
  title: "Signals",
  order: 80,
  purpose: "Document typed message envelopes and routing patterns for inter-agent coordination",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Create stable signal contracts",
    "Route signals without over-coupling producers and consumers",
    "Use metadata for traceability and debugging"
  ],
  repos: ["jido_signal", "jido"],
  source_modules: ["Jido.Signal"],
  source_files: ["lib/jido/signal.ex"],
  status: :draft,
  priority: :high,
  prerequisites: ["docs/key-concepts"],
  related: ["docs/actions", "docs/agent-server", "training/signals-routing", "build/multi-agent-workflows"],
  ecosystem_packages: ["jido_signal", "jido"],
  destination_route: "/docs/signals",
  destination_collection: :pages,
  tags: [:docs, :core, :signals, :coordination]
}
---
## Content Brief

Signal structure, metadata, routing, and practical coordination guidance.

### Validation Criteria

- Signal fields and helpers align with source definitions
- Routing guidance reflects runtime behavior in AgentServer
- Includes idempotency and duplicate-delivery considerations
