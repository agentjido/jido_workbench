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
  prompt_overrides: %{
    document_intent: "Write the authoritative definition of what an Agent means in the Agent Jido ecosystem, with explicit runtime semantics and operational boundaries.",
    required_sections: ["What an Agent Is (and Is Not)", "Agent Lifecycle and Command Boundary", "API Surface Map"],
    must_include: ["Explain `cmd/2` return semantics and how directives are produced from command handling",
     "Differentiate `Jido.Agent`, `Jido.Agent.Cmd`, and `Jido.Agent.Strategy` responsibilities",
     "Include a strategy comparison table with selection guidance"],
    must_avoid: ["General AI-agent definitions that are not tied to Jido runtime behavior"],
    required_links: ["/docs/concepts/actions", "/docs/concepts/signals", "/docs/concepts/directives",
     "/docs/operations/production-readiness-checklist", "/docs/reference/packages/jido"],
    min_words: 1_000,
    max_words: 1_900,
    minimum_code_blocks: 2,
    diagram_policy: "optional"
  },
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
