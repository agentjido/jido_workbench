%{
  title: "Learning Paths",
  order: 10,
  purpose: "Package role-based learning tracks so teams can onboard consistently across functions",
  audience: :beginner,
  content_type: :guide,
  learning_outcomes: [
    "Choose the right learning track by role",
    "Progress from first build to production readiness",
    "Use shared milestones to align team onboarding"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentPlan"],
  source_files: ["marketing/persona-journeys.md", "priv/content_plan/training/**/*.md"],
  status: :outline,
  priority: :medium,
  prerequisites: ["build/quickstarts-by-persona"],
  related: ["training/agent-fundamentals", "training/manager-roadmap", "community/adoption-playbooks"],
  ecosystem_packages: ["agent_jido"],
  destination_route: "/community/learning-paths",
  destination_collection: :pages,
  tags: [:community, :learning, :enablement]
}
---
## Content Brief

Role-based path planner for engineers, platform operators, and technical leaders.

### Validation Criteria

- Each role track includes baseline, intermediate, and production checkpoints
- Tracks link to concrete training modules and build examples
- Includes expected time-to-completion guidance
