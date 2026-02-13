%{
  title: "Docs Overview",
  order: 1,
  purpose: "Provide a self-serve map of canonical docs paths and how they connect to Build, Training, Operate, and Reference",
  audience: :beginner,
  content_type: :guide,
  learning_outcomes: [
    "Navigate the Jido docs structure effectively",
    "Choose the right docs path for current intent",
    "Find next-step implementation and operations guidance quickly"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentPlan"],
  source_files: ["marketing/content-outline.md", "priv/content_plan/**/*.md"],
  status: :outline,
  priority: :high,
  prerequisites: [],
  related: [
    "docs/getting-started-hub",
    "docs/core-concepts-hub",
    "docs/guides-hub",
    "docs/reference-hub",
    "build/quickstarts-by-persona"
  ],
  ecosystem_packages: ["agent_jido"],
  tags: [:docs, :navigation, :self_serve]
}
---
## Content Brief

Entry page for `/docs` that routes users by intent: learn, build, troubleshoot, or verify exact API details.

### Validation Criteria

- Includes clear routing for beginner, implementation, and operations intents
- Links each route to Build, Training, Operate, and Reference destinations
- Keeps page copy compact and action-oriented
