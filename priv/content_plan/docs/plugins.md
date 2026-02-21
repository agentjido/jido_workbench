%{
  priority: :medium,
  status: :outline,
  title: "Plugins",
  repos: ["jido"],
  tags: [:docs, :plugins, :extensibility, :hub_concepts, :format_markdown, :wave_2],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/concepts/plugins",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Define plugin modules with clear boundaries", "Attach plugins to agents safely",
   "Understand plugin lifecycle and routing implications"],
  order: 110,
  prerequisites: ["docs/agents", "docs/actions"],
  purpose: "Describe plugin-based extension patterns for reusable capabilities and runtime composition",
  related: ["docs/agent-server", "build/reference-architectures", "ecosystem/package-selection-by-use-case"],
  source_files: ["lib/jido/plugin.ex"],
  source_modules: ["Jido.Plugin"]
}
---
## Content Brief

Plugin composition guide for reusable behavior layers.

### Validation Criteria

- Callback and option coverage matches source APIs
- Includes guidance on plugin-scoped state and side-effect boundaries
- Links to architecture and operations pages where plugin choices matter
