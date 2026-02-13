%{
  title: "Agents",
  order: 60,
  purpose: "Define how to model agents, state schemas, lifecycle hooks, and command handling",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Define agents with validation-friendly schemas",
    "Use lifecycle hooks correctly",
    "Choose execution strategy by workload profile"
  ],
  repos: ["jido"],
  source_modules: ["Jido.Agent", "Jido.Agent.Cmd", "Jido.Agent.Strategy"],
  source_files: ["lib/jido/agent.ex", "lib/jido/agent/cmd.ex", "lib/jido/agent/strategy.ex"],
  status: :draft,
  priority: :high,
  prerequisites: ["docs/key-concepts"],
  related: ["docs/actions", "docs/directives", "docs/plugins", "operate/agent-server", "operate/testing-agents-and-actions"],
  ecosystem_packages: ["jido"],
  tags: [:docs, :core, :agents]
}
---
## Content Brief

Definitive guide to agent definition and command semantics.

### Validation Criteria

- Hook signatures and option names match source typespecs
- Strategy descriptions map to available implementations
- Includes links to runtime operations implications
