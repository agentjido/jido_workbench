%{
  title: "Build Your First Agent",
  order: 20,
  purpose: "Walk a new user from setup to a running agent workflow that demonstrates the Jido command model",
  audience: :beginner,
  content_type: :tutorial,
  learning_outcomes: [
    "Define an agent module with typed state",
    "Implement an action and execute it via cmd/2",
    "Interpret updated state and returned directives"
  ],
  repos: ["jido", "jido_action"],
  source_modules: ["Jido.Agent", "Jido.Action"],
  source_files: ["lib/jido/agent.ex", "lib/jido/action.ex"],
  status: :review,
  priority: :critical,
  prerequisites: ["build/installation"],
  related: [
    "docs/key-concepts",
    "build/counter-agent",
    "training/agent-fundamentals",
    "docs/actions"
  ],
  ecosystem_packages: ["jido", "jido_action"],
  tags: [:build, :agents, :tutorial]
}
---
## Content Brief

Canonical hello-world build flow.

Cover:

- Create a simple counter-like agent with `use Jido.Agent`
- Add one action with schema-validated params
- Execute `cmd/2` and inspect deterministic state transitions
- Explain directive output and why side effects are deferred

### Validation Criteria

- Code compiles against the current Jido API
- `cmd/2` contract explanation matches source types and behavior
- Page links forward to counter example and fundamentals training
