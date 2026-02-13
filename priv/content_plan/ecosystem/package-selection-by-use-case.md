%{
  title: "Package Selection by Use Case",
  order: 3,
  purpose: "Help teams pick a minimal Jido package set based on concrete product and operations needs",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Select package combinations for common AI product patterns",
    "Avoid over-adopting packages before operational readiness",
    "Map each selection to next-step implementation guides"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.Ecosystem", "AgentJidoWeb.JidoEcosystemPackageLive"],
  source_files: [
    "lib/agent_jido/ecosystem.ex",
    "lib/agent_jido_web/live/jido_ecosystem_package_live.ex",
    "marketing/content-outline.md",
    "marketing/persona-journeys.md"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["ecosystem/package-matrix"],
  related: [
    "build/product-feature-blueprints",
    "build/mixed-stack-integration",
    "docs/production-readiness-checklist"
  ],
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai", "req_llm", "agent_jido"],
  destination_route: "/ecosystem/package-selection-by-use-case",
  destination_collection: :ecosystem,
  tags: [:ecosystem, :decision, :use_case]
}
---
## Content Brief

Decision guide grouped by scenarios such as chat assistants, long-running orchestration, and mixed-stack service boundaries.

### Validation Criteria

- Includes minimal, recommended, and advanced package sets per use case
- Includes explicit off-ramps when a package is not yet needed
- Links each use case to one runnable Build example
