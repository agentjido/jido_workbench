%{
  title: "Quickstarts by Persona",
  order: 80,
  purpose: "Provide role-specific starting paths so each persona can reach first value quickly",
  audience: :beginner,
  content_type: :guide,
  learning_outcomes: [
    "Pick the right quickstart path for your role and stack",
    "Complete a bounded first milestone in under one session",
    "Know the next Build, Training, and Operate steps"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentPlan"],
  source_files: [
    "marketing/persona-journeys.md",
    "marketing/content-outline.md",
    "priv/content_plan/**/*.md"
  ],
  status: :outline,
  priority: :critical,
  prerequisites: ["features/overview", "ecosystem/package-matrix"],
  related: [
    "build/installation",
    "build/first-agent",
    "training/agent-fundamentals",
    "docs/production-readiness-checklist"
  ],
  ecosystem_packages: ["agent_jido"],
  destination_route: "/build/quickstarts-by-persona",
  destination_collection: :pages,
  tags: [:build, :persona, :quickstart, :journeys]
}
---
## Content Brief

Persona router page for:

- Elixir platform engineer
- AI product engineer
- Python AI engineer
- TypeScript fullstack engineer
- Platform/SRE engineer

### Validation Criteria

- Each persona path has a concrete first action and expected outcome
- Each path links to exactly one next step in Training and one in Operate/Reference
- Aligns with canonical journeys in `marketing/persona-journeys.md`
