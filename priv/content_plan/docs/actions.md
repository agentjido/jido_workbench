%{
  priority: :high,
  status: :draft,
  title: "Actions",
  repos: ["jido_action", "jido"],
  tags: [:docs, :core, :actions, :hub_concepts, :format_livebook, :wave_1],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/concepts/actions",
  ecosystem_packages: ["jido_action", "jido"],
  learning_outcomes: ["Define actions with robust parameter schemas", "Compose actions safely in command pipelines",
   "Test actions in isolation and in agent flows"],
  order: 70,
  prerequisites: ["docs/key-concepts"],
  purpose: "Explain how to define, validate, compose, and test reusable action modules",
  related: ["docs/agents", "docs/directives", "training/actions-validation", "build/tool-use"],
  source_files: ["lib/jido/action.ex"],
  source_modules: ["Jido.Action"]
}
---
## Content Brief

Action contracts, composition, and validation-focused patterns.

### Validation Criteria

- Callback signatures and return conventions match source
- Composition semantics match `cmd/2` behavior
- Includes links to testing and tool-use implementation guides
