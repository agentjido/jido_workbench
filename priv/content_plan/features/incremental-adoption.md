%{
  title: "Incremental Adoption Paths",
  order: 4,
  purpose: "Define phased adoption plans that let teams prove value before deep platform commitment",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Plan bounded pilots with clear reliability success criteria",
    "Scale from single-workflow deployment to multi-team adoption",
    "Align package adoption with training and operations maturity"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.Ecosystem", "AgentJido.ContentPlan"],
  source_files: [
    "marketing/persona-journeys.md",
    "marketing/content-governance.md",
    "lib/agent_jido/ecosystem.ex",
    "lib/agent_jido/content_plan.ex"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["ecosystem/package-matrix"],
  related: [
    "features/executive-brief",
    "training/manager-roadmap",
    "docs/security-and-governance",
    "community/adoption-playbooks"
  ],
  ecosystem_packages: ["jido", "jido_ai", "agent_jido"],
  destination_route: "/features/incremental-adoption",
  destination_collection: :pages,
  tags: [:ecosystem, :adoption, :governance, :roadmap]
}
---
## Content Brief

Phased rollout playbook based on Awareness -> Evaluation -> Activation -> Operationalization -> Expansion.

### Validation Criteria

- Includes explicit phase gates and stop/go criteria
- Maps each phase to required proof assets (example + training + operate/reference)
- Includes ownership guidance across engineering, platform, and content governance roles
