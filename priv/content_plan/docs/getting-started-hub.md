%{
  title: "Getting Started Docs Hub",
  order: 10,
  purpose: "Consolidate first-step docs paths and reduce new-user confusion",
  audience: :beginner,
  content_type: :guide,
  learning_outcomes: [
    "Complete the fastest safe onboarding path",
    "Understand required prerequisites before advanced guides",
    "Transition into hands-on Build and Training flows"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentPlan"],
  source_files: ["marketing/content-outline.md", "marketing/persona-journeys.md"],
  status: :outline,
  priority: :high,
  prerequisites: ["docs/overview"],
  related: ["build/installation", "build/first-agent", "training/agent-fundamentals"],
  ecosystem_packages: ["agent_jido"],
  tags: [:docs, :getting_started, :navigation]
}
---
## Content Brief

Hub page that groups setup, first agent, and core mental models with explicit next steps.

### Validation Criteria

- Includes expected completion time for each recommended path
- Includes direct links into Build and Training modules
- Avoids duplicating detailed implementation content
