%{
  title: "Adoption Playbooks",
  order: 20,
  purpose: "Codify repeatable rollout patterns for teams moving from pilot to standardized adoption",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Run phased adoption programs with clear ownership",
    "Use readiness gates to reduce rollout risk",
    "Scale successful patterns across multiple teams"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentPlan"],
  source_files: ["marketing/persona-journeys.md", "marketing/content-governance.md", "priv/content_plan/docs/**/*.md"],
  status: :outline,
  priority: :high,
  prerequisites: ["docs/production-readiness-checklist", "features/incremental-adoption"],
  related: [
    "community/case-studies",
    "training/manager-roadmap",
    "docs/incident-playbooks",
    "docs/content-governance-and-drift-detection"
  ],
  ecosystem_packages: ["agent_jido", "jido"],
  destination_route: "/community/adoption-playbooks",
  destination_collection: :pages,
  tags: [:community, :adoption, :operations, :governance]
}
---
## Content Brief

Operational adoption playbook for pilot launch, expansion, and standardization phases.

### Validation Criteria

- Includes 30/60/90 rollout framework with ownership model
- Includes common failure modes and mitigation guidance
- Includes required evidence artifacts for each phase gate
