%{
  priority: :high,
  status: :draft,
  title: "Agents",
  related: ["docs/actions", "docs/directives", "docs/plugins", "docs/agent-server", "docs/testing-agents-and-actions",
   "build/first-agent"],
  repos: ["jido"],
  tags: [:docs, :core, :agents, :hub_concepts, :format_markdown, :wave_1],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/concepts/agents",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Define agents with validation-friendly schemas", "Use lifecycle hooks correctly",
   "Choose execution strategy by workload profile"],
  order: 60,
  prerequisites: ["docs/key-concepts"],
  purpose: "Define how to model agents, state schemas, lifecycle hooks, and command handling",
  source_files: ["lib/jido/agent.ex", "lib/jido/agent/cmd.ex", "lib/jido/agent/strategy.ex"],
  source_modules: ["Jido.Agent", "Jido.Agent.Cmd", "Jido.Agent.Strategy"]
}
---
## Content Brief

Definitive guide to agent definition and command semantics.

### Validation Criteria

- Hook signatures and option names match source typespecs
- Strategy descriptions map to available implementations
- Includes links to runtime operations implications
