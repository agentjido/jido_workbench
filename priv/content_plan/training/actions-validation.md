%{
  title: "Actions and Schema Validation",
  order: 20,
  purpose: "Cover action contract design and validation boundaries for safe state transitions",
  audience: :beginner,
  content_type: :tutorial,
  learning_outcomes: [
    "Design clear action parameter contracts",
    "Apply required and default field validation",
    "Return predictable error payloads"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Action", "AgentJido.Training"],
  source_files: ["priv/training/actions-validation.md", "lib/agent_jido/training.ex"],
  status: :published,
  priority: :high,
  prerequisites: ["training/agent-fundamentals"],
  related: ["training/signals-routing", "features/schema-validated-actions", "docs/actions", "build/tool-use"],
  ecosystem_packages: ["jido", "agent_jido"],
  destination_route: "/training/actions-validation",
  destination_collection: :training,
  tags: [:training, :actions, :validation]
}
---
## Content Brief

Hands-on module for schema-safe action design and validation error handling.

### Validation Criteria

- Includes practical exercise and checklist sections
- Related links point to docs and build tool-use content
- Ordering keeps this module before signal routing
