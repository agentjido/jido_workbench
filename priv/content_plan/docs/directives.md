%{
  title: "Directives",
  order: 90,
  purpose: "Explain how agents describe side effects declaratively and how runtime execution handles those requests",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Return directives instead of side effects",
    "Use built-in directive types safely",
    "Reason about directive execution and ordering"
  ],
  repos: ["jido"],
  source_modules: ["Jido.Agent.Directive"],
  source_files: ["lib/jido/agent/directive.ex"],
  status: :outline,
  priority: :high,
  prerequisites: ["docs/agents", "docs/actions"],
  related: ["docs/signals", "operate/agent-server", "training/directives-scheduling"],
  ecosystem_packages: ["jido"],
  tags: [:docs, :core, :directives, :effects]
}
---
## Content Brief

Directive model and runtime execution semantics.

### Validation Criteria

- Built-in directive list matches source
- Struct field references are accurate
- Includes links to schedule loops and operations recovery guides
