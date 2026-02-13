%{
  title: "Key Concepts",
  order: 50,
  purpose: "Establish the core mental model for Jido before deeper implementation",
  audience: :beginner,
  content_type: :explanation,
  learning_outcomes: [
    "Understand agents as immutable structures",
    "Understand cmd/2 as the command boundary",
    "Differentiate actions, signals, and directives",
    "Understand pure logic versus runtime effects"
  ],
  repos: ["jido", "jido_action", "jido_signal"],
  source_modules: ["Jido.Agent", "Jido.Action", "Jido.Signal", "Jido.Agent.Directive"],
  source_files: ["lib/jido/agent.ex", "lib/jido/action.ex", "lib/jido/signal.ex", "lib/jido/agent/directive.ex"],
  status: :draft,
  priority: :high,
  prerequisites: ["docs/getting-started", "build/first-agent"],
  related: [
    "docs/agents",
    "docs/actions",
    "docs/signals",
    "docs/directives",
    "ecosystem/package-matrix"
  ],
  ecosystem_packages: ["jido", "jido_action", "jido_signal"],
  destination_route: "/docs/key-concepts",
  destination_collection: :pages,
  tags: [:docs, :concepts, :foundation]
}
---
## Content Brief

Conceptual overview with diagrams encouraged.

Cover:

- Signal -> AgentServer -> cmd/2 -> {agent, directives} flow
- Layer model: pure primitives vs effectful runtime
- Terminology mapping used across the rest of docs

### Validation Criteria

- Terminology matches module names and docs in source code
- No behavior claims beyond current implementation
- Links to next deep dives and first operations guide
