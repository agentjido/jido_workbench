%{
  title: "Agents",
  order: 1,
  purpose: "Complete guide to defining, configuring, and using Jido agents",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Define agents with custom schemas and validations",
    "Use lifecycle hooks (on_before_cmd, on_after_cmd)",
    "Configure execution strategies (Direct, FSM)",
    "Understand agent state immutability guarantees"
  ],
  repos: ["jido"],
  source_modules: ["Jido.Agent", "Jido.Agent.Cmd", "Jido.Agent.Strategy"],
  source_files: ["lib/jido/agent.ex", "lib/jido/agent/cmd.ex", "lib/jido/agent/strategy.ex"],
  status: :planned,
  priority: :high,
  prerequisites: ["key-concepts"],
  related: ["actions", "directives", "plugins", "agent-server"],
  ecosystem_packages: ["jido"],
  tags: [:core, :agents]
}
---
## Content Brief

The definitive guide to Jido.Agent. Cover:

- Agent definition with `use Jido.Agent`
- Schema definition and validation options (NimbleOptions, Zoi)
- The cmd/2 contract in detail
- Lifecycle hooks and when to use them
- Execution strategies: Direct vs FSM
- Agent identity and metadata

### Validation Criteria
- All `use Jido.Agent` options must match source code
- Lifecycle hook signatures must match typespec
- Strategy names must match available implementations
