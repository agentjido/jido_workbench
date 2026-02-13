%{
  title: "Ecosystem Package Matrix",
  order: 2,
  purpose: "Map each package to responsibilities, dependencies, and recommended adoption sequence",
  audience: :intermediate,
  content_type: :reference,
  learning_outcomes: [
    "Identify which packages are required for each use case",
    "Understand dependency relationships across the ecosystem",
    "Choose incremental adoption paths by team maturity"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.Ecosystem", "AgentJidoWeb.JidoEcosystemLive", "AgentJidoWeb.JidoEcosystemPackageLive"],
  source_files: [
    "lib/agent_jido/ecosystem.ex",
    "lib/agent_jido_web/live/jido_ecosystem_live.ex",
    "lib/agent_jido_web/live/jido_ecosystem_package_live.ex",
    "marketing/persona-journeys.md"
  ],
  status: :draft,
  priority: :critical,
  prerequisites: ["ecosystem/overview"],
  related: [
    "ecosystem/package-selection-by-use-case",
    "features/composable-ecosystem",
    "build/quickstarts-by-persona",
    "docs/architecture-decision-guides"
  ],
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai", "req_llm", "llm_db", "agent_jido"],
  destination_route: "/ecosystem/package-matrix",
  destination_collection: :ecosystem,
  tags: [:ecosystem, :reference, :packages, :adoption]
}
---
## Content Brief

Canonical matrix that pairs package capabilities with architecture responsibilities and maturity guidance.

### Validation Criteria

- Dependency edges align with `AgentJido.Ecosystem` graph metadata
- Recommended package bundles map to documented persona journeys
- Every matrix row links to at least one Build, Training, or Operate page
