%{
  title: "Reference Architectures",
  order: 90,
  purpose: "Offer implementation-ready architecture blueprints for common Jido deployment patterns",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Choose an architecture pattern that matches product and reliability constraints",
    "Map package choices to runtime topology and ownership boundaries",
    "Apply readiness checks before production rollout"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.Ecosystem", "Jido.AgentServer"],
  source_files: [
    "marketing/content-outline.md",
    "marketing/persona-journeys.md",
    "lib/agent_jido/ecosystem.ex"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["ecosystem/package-matrix", "build/quickstarts-by-persona"],
  related: [
    "build/mixed-stack-integration",
    "build/product-feature-blueprints",
    "reference/architecture-decision-guides",
    "operate/production-readiness-checklist"
  ],
  ecosystem_packages: ["jido", "jido_signal", "jido_action", "agent_jido"],
  tags: [:build, :architecture, :blueprints]
}
---
## Content Brief

Blueprint library for single-agent service, orchestration hub, and mixed-stack boundary patterns.

### Validation Criteria

- Includes at least three architecture patterns with tradeoffs
- Each pattern names required and optional packages
- Each pattern links to the corresponding runbook/readiness checklist
