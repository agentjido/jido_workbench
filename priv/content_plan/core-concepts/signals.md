%{
  title: "Signals",
  order: 3,
  purpose: "Understanding the typed message envelope system for agent communication",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Create and dispatch signals between agents",
    "Understand signal routing in AgentServer",
    "Define custom signal types",
    "Use signal metadata and correlation IDs"
  ],
  repos: ["jido_signal"],
  source_modules: ["Jido.Signal"],
  source_files: ["lib/jido/signal.ex"],
  status: :planned,
  priority: :high,
  prerequisites: ["key-concepts"],
  related: ["agent-server", "actions"],
  ecosystem_packages: ["jido_signal"],
  tags: [:core, :signals, :communication]
}
---
## Content Brief

The Signal system — Jido's typed message envelope:

- What a Signal is and why not plain messages
- Creating signals
- Signal routing rules
- Signal metadata (correlation, causation, timestamps)
- Dispatching signals to AgentServer

### Validation Criteria
- Signal struct fields must match Jido.Signal source
- Routing semantics must match AgentServer implementation
