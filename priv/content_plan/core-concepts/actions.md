%{
  title: "Actions",
  order: 2,
  purpose: "How to define, compose, and test reusable action modules",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Define actions with parameter schemas",
    "Compose multiple actions in a single cmd/2 call",
    "Test actions in isolation without agents",
    "Understand action return value conventions"
  ],
  repos: ["jido_action"],
  source_modules: ["Jido.Action"],
  source_files: ["lib/jido/action.ex"],
  status: :planned,
  priority: :high,
  prerequisites: ["key-concepts"],
  related: ["agents", "directives"],
  ecosystem_packages: ["jido_action"],
  tags: [:core, :actions]
}
---
## Content Brief

Everything about the Jido.Action behaviour:

- Defining an action with `use Jido.Action`
- Parameter schemas and validation
- The `run/2` callback contract
- Composing actions as lists passed to cmd/2
- Using `{Module, params}` tuples vs `%Instruction{}` structs
- Testing actions in isolation

### Validation Criteria
- Action callback signatures must match source typespec
- Composition semantics must match cmd/2 implementation
