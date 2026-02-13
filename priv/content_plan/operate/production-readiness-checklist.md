%{
  title: "Production Readiness Checklist",
  order: 70,
  purpose: "Define a go-live gate for reliability, observability, and recovery readiness",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Assess production readiness across architecture and operations controls",
    "Identify release blockers before launch",
    "Apply a repeatable readiness review process"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.ContentPlan", "Jido.AgentServer"],
  source_files: ["marketing/content-outline.md", "marketing/content-governance.md", "priv/content_plan/operate/**/*.md"],
  status: :outline,
  priority: :critical,
  prerequisites: ["operate/agent-server", "training/production-readiness"],
  related: [
    "operate/security-and-governance",
    "reference/telemetry-and-observability",
    "reference/migrations-and-upgrade-paths",
    "community/adoption-playbooks"
  ],
  ecosystem_packages: ["jido", "agent_jido"],
  tags: [:operate, :checklist, :production, :readiness]
}
---
## Content Brief

Pre-launch checklist spanning runtime safety, monitoring, rollback, and ownership readiness.

### Validation Criteria

- Includes objective pass/fail criteria per category
- Includes required links to runbooks and telemetry baselines
- Includes explicit sign-off roles (engineering, platform, docs/content)
