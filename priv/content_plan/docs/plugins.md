%{
  title: "Plugins",
  order: 100,
  purpose: "Describe plugin-based extension patterns for reusable capabilities and runtime composition",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Define plugin modules with clear boundaries",
    "Attach plugins to agents safely",
    "Understand plugin lifecycle and routing implications"
  ],
  repos: ["jido"],
  source_modules: ["Jido.Plugin"],
  source_files: ["lib/jido/plugin.ex"],
  status: :outline,
  priority: :medium,
  prerequisites: ["docs/agents", "docs/actions"],
  related: ["docs/agent-server", "build/reference-architectures", "ecosystem/package-selection-by-use-case"],
  ecosystem_packages: ["jido"],
  destination_route: "/docs/plugins",
  destination_collection: :pages,
  tags: [:docs, :plugins, :extensibility]
}
---
## Content Brief

Plugin composition guide for reusable behavior layers.

### Validation Criteria

- Callback and option coverage matches source APIs
- Includes guidance on plugin-scoped state and side-effect boundaries
- Links to architecture and operations pages where plugin choices matter
