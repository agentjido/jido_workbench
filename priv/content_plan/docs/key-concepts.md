%{
  priority: :high,
  status: :draft,
  title: "Key Concepts",
  repos: ["jido", "jido_action", "jido_signal"],
  tags: [:docs, :concepts, :foundation, :hub_concepts, :format_markdown, :wave_1],
  audience: :beginner,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/concepts/key-concepts",
  ecosystem_packages: ["jido", "jido_action", "jido_signal"],
  learning_outcomes: ["Understand agents as immutable structures", "Understand cmd/2 as the command boundary",
   "Differentiate actions, signals, and directives", "Understand pure logic versus runtime effects"],
  order: 50,
  prerequisites: ["docs/getting-started", "build/first-agent"],
  purpose: "Establish the core mental model for Jido before deeper implementation",
  related: ["docs/agents", "docs/actions", "docs/signals", "docs/directives", "ecosystem/package-matrix"],
  source_files: ["lib/jido/agent.ex", "lib/jido/action.ex", "lib/jido/signal.ex", "lib/jido/agent/directive.ex"],
  source_modules: ["Jido.Agent", "Jido.Action", "Jido.Signal", "Jido.Agent.Directive"]
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
