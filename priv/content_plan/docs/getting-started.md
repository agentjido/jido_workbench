%{
  priority: :high,
  status: :outline,
  title: "Getting Started Docs Hub",
  repos: ["agent_jido"],
  tags: [:docs, :getting_started, :navigation, :hub_getting_started, :format_livebook, :wave_1],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/getting-started",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Complete the fastest safe onboarding path",
   "Understand required prerequisites before advanced guides", "Transition into hands-on Build and Training flows"],
  order: 10,
  prerequisites: ["docs/overview"],
  purpose: "Consolidate first-step docs paths and reduce new-user confusion",
  related: ["build/installation", "build/first-agent", "training/agent-fundamentals"],
  source_files: ["marketing/content-outline.md", "marketing/persona-journeys.md"],
  source_modules: ["AgentJido.ContentPlan"]
}
---
## Content Brief

Hub page that groups setup, first agent, and core mental models with explicit next steps.

### Validation Criteria

- Includes expected completion time for each recommended path
- Includes direct links into Build and Training modules
- Avoids duplicating detailed implementation content
