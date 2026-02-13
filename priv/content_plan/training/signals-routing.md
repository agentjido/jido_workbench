%{
  title: "Signals, Routing, and Agent Communication",
  order: 30,
  purpose: "Teach event-driven coordination using stable signal contracts and explicit routing",
  audience: :intermediate,
  content_type: :tutorial,
  learning_outcomes: [
    "Design stable domain signal names",
    "Route signals without coupling producers to consumers",
    "Handle duplicate delivery through idempotent handlers"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Signal", "AgentJido.Training"],
  source_files: ["priv/training/signals-routing.md", "lib/agent_jido/training.ex"],
  status: :published,
  priority: :high,
  prerequisites: ["training/actions-validation"],
  related: ["training/directives-scheduling", "features/signal-routing-and-coordination", "docs/signals", "build/multi-agent-workflows"],
  ecosystem_packages: ["jido_signal", "jido", "agent_jido"],
  tags: [:training, :signals, :routing, :coordination]
}
---
## Content Brief

Intermediate module for robust inter-agent communication patterns.

### Validation Criteria

- Includes idempotency and duplicate-delivery guidance
- Connects directly to directives and multi-agent implementation
- Uses routing semantics that match source behavior
