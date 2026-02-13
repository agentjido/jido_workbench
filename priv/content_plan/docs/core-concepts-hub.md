%{
  title: "Core Concepts Docs Hub",
  order: 20,
  purpose: "Provide a conceptual index for agent primitives and runtime behavior",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Understand conceptual dependencies among core primitives",
    "Select the right deep-dive doc for current implementation need",
    "Connect concepts to practical Build and Operate guides"
  ],
  repos: ["jido"],
  source_modules: ["Jido.Agent", "Jido.Action", "Jido.Signal", "Jido.Agent.Directive"],
  source_files: ["lib/jido/agent.ex", "lib/jido/action.ex", "lib/jido/signal.ex", "lib/jido/agent/directive.ex"],
  status: :outline,
  priority: :high,
  prerequisites: ["docs/overview"],
  related: ["docs/key-concepts", "docs/agents", "docs/actions", "docs/signals", "docs/directives", "docs/plugins"],
  ecosystem_packages: ["jido", "jido_action", "jido_signal"],
  tags: [:docs, :core, :concepts]
}
---
## Content Brief

Index page that introduces and sequences core concept docs.

### Validation Criteria

- Shows dependency order between concepts
- Links each concept to at least one Build example
- Includes one Operate cross-link for production implications
