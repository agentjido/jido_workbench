%{
  title: "Key Concepts",
  order: 3,
  purpose: "Establish the mental model for how Jido works before diving deeper",
  audience: :beginner,
  content_type: :explanation,
  learning_outcomes: [
    "Understand agents as immutable data structures",
    "Understand the cmd/2 contract and its Elm/Redux inspiration",
    "Know the difference between actions, directives, and signals",
    "Understand the separation of pure logic from effectful runtime"
  ],
  repos: ["jido", "jido_action", "jido_signal"],
  source_modules: ["Jido.Agent", "Jido.Action", "Jido.Signal", "Jido.Agent.Directive"],
  source_files: [],
  status: :planned,
  priority: :high,
  prerequisites: ["first-agent"],
  related: ["agents", "actions", "signals", "directives"],
  ecosystem_packages: ["jido", "jido_action", "jido_signal"],
  tags: [:getting_started, :concepts]
}
---
## Content Brief

A conceptual overview — no code required but diagrams encouraged. Cover:

- **Agents** are immutable structs, not processes
- **cmd/2** is the single entry point: actions in, updated agent + directives out
- **Actions** are pure transformation modules
- **Directives** describe side effects without performing them
- **Signals** are typed message envelopes for inter-agent communication
- **AgentServer** is the OTP runtime that executes directives

### Diagrams Needed
- Data flow: Signal → AgentServer → cmd/2 → {Agent, Directives}
- Layer diagram: Pure (Agent, Action) vs Effectful (AgentServer, Runtime)

### Validation Criteria
- Terminology must match module names and @moduledoc in source code
- No claims about features that don't exist in source
