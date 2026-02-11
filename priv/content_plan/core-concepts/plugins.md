%{
  title: "Plugins",
  order: 5,
  purpose: "Extending agents with composable, reusable capability modules",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Define a plugin module with actions and state",
    "Attach plugins to agents",
    "Use plugin lifecycle hooks",
    "Understand plugin signal routing rules"
  ],
  repos: ["jido"],
  source_modules: ["Jido.Plugin"],
  source_files: ["lib/jido/plugin.ex"],
  status: :planned,
  priority: :medium,
  prerequisites: ["agents", "actions"],
  related: ["agent-server"],
  ecosystem_packages: ["jido"],
  tags: [:core, :plugins, :extensibility]
}
---
## Content Brief

The Plugin system — composable agent extensions:

- Plugin behaviour and callbacks
- Encapsulating actions, state, config, routes, hooks, children, and cron
- Attaching plugins to agent definitions
- Plugin lifecycle hooks
- Plugin-scoped state isolation

### Validation Criteria
- Plugin callbacks must match Jido.Plugin source
- Configuration options must match source docs
