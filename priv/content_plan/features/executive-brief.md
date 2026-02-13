%{
  title: "Executive Brief",
  order: 4,
  purpose: "Give decision-makers a concise reliability, ROI, and adoption-risk framing for Jido",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Frame Jido adoption as risk reduction for production AI workflows",
    "Define phased 30/60/90 adoption checkpoints",
    "Align engineering and platform ownership across rollout phases"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.Ecosystem", "AgentJidoWeb.Router"],
  source_files: [
    "marketing/positioning.md",
    "marketing/persona-journeys.md",
    "marketing/content-governance.md",
    "lib/agent_jido/ecosystem.ex",
    "lib/agent_jido_web/router.ex"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["features/overview"],
  related: [
    "ecosystem/package-matrix",
    "build/reference-architectures",
    "training/manager-roadmap",
    "docs/security-and-governance"
  ],
  ecosystem_packages: ["jido", "jido_ai", "jido_signal", "agent_jido"],
  destination_route: "/features/executive-brief",
  destination_collection: :pages,
  tags: [:features, :executive, :adoption, :governance]
}
---
## Content Brief

Leadership-facing page for CTO, VP Engineering, and architecture leads.

Cover:

- Strategic problem statement: prototype success vs production reliability
- Adoption model: bounded pilot, operationalization, expansion
- Decision criteria: uptime risk, incident load, maintainability, and team enablement
- Cross-functional ownership model across engineering, platform, and docs/content governance

### Validation Criteria

- Includes a clear 30/60/90 plan with measurable gates
- Includes cross-links to package matrix, operate baseline, and manager training roadmap
- Keeps claims bounded to demonstrable system behavior
