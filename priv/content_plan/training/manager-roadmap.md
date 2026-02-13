%{
  title: "Manager Adoption Roadmap",
  order: 70,
  purpose: "Provide engineering managers a phased enablement plan for adopting Jido across teams",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Plan team enablement milestones across 30/60/90 windows",
    "Define success criteria for pilot, launch, and expansion phases",
    "Coordinate ownership across engineering, platform, and operations"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentPlan"],
  source_files: ["marketing/persona-journeys.md", "marketing/content-governance.md", "priv/content_plan/**/*.md"],
  status: :outline,
  priority: :high,
  prerequisites: ["training/agent-fundamentals", "operate/production-readiness-checklist"],
  related: ["why/executive-brief", "community/adoption-playbooks", "operate/security-and-governance"],
  ecosystem_packages: ["agent_jido"],
  tags: [:training, :management, :adoption, :roadmap]
}
---
## Content Brief

Leadership-oriented training page for rollout sequencing, risk control, and team capability planning.

### Validation Criteria

- Includes role-based ownership matrix and cadence recommendations
- Includes objective milestones for pilot, operationalization, and expansion
- Links to adoption playbooks and governance references
