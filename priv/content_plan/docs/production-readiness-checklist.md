%{
  priority: :critical,
  status: :outline,
  title: "Production Readiness Checklist",
  repos: ["agent_jido", "jido"],
  tags: [:operate, :checklist, :production, :readiness, :hub_operations, :format_markdown, :wave_1],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/operations/production-readiness-checklist",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Assess production readiness across architecture and operations controls",
   "Identify release blockers before launch", "Apply a repeatable readiness review process"],
  order: 350,
  prerequisites: ["docs/agent-server", "training/production-readiness"],
  purpose: "Define a go-live gate for reliability, observability, and recovery readiness",
  related: ["docs/security-and-governance", "docs/telemetry-and-observability", "docs/migrations-and-upgrade-paths",
   "community/adoption-playbooks"],
  source_files: ["marketing/content-outline.md", "marketing/content-governance.md", "priv/content_plan/docs/**/*.md"],
  source_modules: ["AgentJido.ContentPlan", "Jido.AgentServer"]
}
---
## Content Brief

Pre-launch checklist spanning runtime safety, monitoring, rollback, and ownership readiness.

### Validation Criteria

- Includes objective pass/fail criteria per category
- Includes required links to runbooks and telemetry baselines
- Includes explicit sign-off roles (engineering, platform, docs/content)
