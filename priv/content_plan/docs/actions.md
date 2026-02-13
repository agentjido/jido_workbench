%{
  title: "Actions",
  order: 70,
  purpose: "Explain how to define, validate, compose, and test reusable action modules",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Define actions with robust parameter schemas",
    "Compose actions safely in command pipelines",
    "Test actions in isolation and in agent flows"
  ],
  repos: ["jido_action", "jido"],
  source_modules: ["Jido.Action"],
  source_files: ["lib/jido/action.ex"],
  status: :draft,
  priority: :high,
  prerequisites: ["docs/key-concepts"],
  related: ["docs/agents", "docs/directives", "training/actions-validation", "build/tool-use"],
  ecosystem_packages: ["jido_action", "jido"],
  tags: [:docs, :core, :actions]
}
---
## Content Brief

Action contracts, composition, and validation-focused patterns.

### Validation Criteria

- Callback signatures and return conventions match source
- Composition semantics match `cmd/2` behavior
- Includes links to testing and tool-use implementation guides
