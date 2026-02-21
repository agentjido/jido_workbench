%{
  priority: :high,
  status: :outline,
  title: "Docs Overview",
  repos: ["agent_jido"],
  tags: [:docs, :navigation, :self_serve, :hub_getting_started, :format_markdown, :wave_1],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Navigate the Jido docs structure effectively", "Choose the right docs path for current intent",
   "Find next-step implementation and operations guidance quickly"],
  order: 1,
  prerequisites: [],
  purpose: "Provide a self-serve map of canonical docs paths and how they connect to Build, Training, Operate, and Reference",
  related: ["docs/getting-started", "docs/core-concepts", "docs/guides", "docs/reference",
   "build/quickstarts-by-persona"],
  source_files: ["marketing/content-outline.md", "priv/content_plan/**/*.md"],
  source_modules: ["AgentJido.ContentPlan"]
}
---
## Content Brief

Entry page for `/docs` that routes users by intent: learn, build, troubleshoot, or verify exact API details.

### Validation Criteria

- Includes clear routing for beginner, implementation, and operations intents
- Links each route to Build, Training, Operate, and Reference destinations
- Keeps page copy compact and action-oriented
