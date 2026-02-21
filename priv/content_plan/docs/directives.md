%{
  priority: :high,
  status: :outline,
  title: "Directives",
  repos: ["jido"],
  tags: [:docs, :core, :directives, :effects, :hub_concepts, :format_livebook, :wave_1],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/concepts/directives",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Return directives instead of side effects", "Use built-in directive types safely",
   "Reason about directive execution and ordering"],
  order: 90,
  prerequisites: ["docs/agents", "docs/actions"],
  purpose: "Explain how agents describe side effects declaratively and how runtime execution handles those requests",
  related: ["docs/signals", "docs/agent-server", "training/directives-scheduling"],
  source_files: ["lib/jido/agent/directive.ex"],
  source_modules: ["Jido.Agent.Directive"]
}
---
## Content Brief

Directive model and runtime execution semantics.

### Validation Criteria

- Built-in directive list matches source
- Struct field references are accurate
- Includes links to schedule loops and operations recovery guides
