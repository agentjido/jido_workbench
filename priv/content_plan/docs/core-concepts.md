%{
  priority: :high,
  status: :outline,
  title: "Core Concepts Docs Hub",
  related: ["docs/key-concepts", "docs/agents", "docs/actions", "docs/signals", "docs/directives", "docs/plugins",
   "training/agent-fundamentals"],
  repos: ["jido"],
  tags: [:docs, :core, :concepts, :hub_concepts, :format_markdown, :wave_1],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/concepts",
  ecosystem_packages: ["jido", "jido_action", "jido_signal"],
  learning_outcomes: ["Understand conceptual dependencies among core primitives",
   "Select the right deep-dive doc for current implementation need",
   "Connect concepts to practical Build and Operate guides"],
  order: 20,
  prerequisites: ["docs/overview"],
  purpose: "Provide a conceptual index for agent primitives and runtime behavior",
  source_files: ["lib/jido/agent.ex", "lib/jido/action.ex", "lib/jido/signal.ex", "lib/jido/agent/directive.ex"],
  source_modules: ["Jido.Agent", "Jido.Action", "Jido.Signal", "Jido.Agent.Directive"]
}
---
## Content Brief

Index page that introduces and sequences core concept docs.

### Validation Criteria

- Shows dependency order between concepts
- Links each concept to at least one Build example
- Includes one Operate cross-link for production implications
