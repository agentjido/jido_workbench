%{
  title: "Ecosystem Overview",
  order: 1,
  purpose: "Orient builders to the Jido package landscape and how layers fit together in a runtime architecture",
  audience: :beginner,
  content_type: :explanation,
  learning_outcomes: [
    "Understand ecosystem layers from runtime core to integrations",
    "Identify minimal package sets for first production use cases",
    "Navigate from ecosystem discovery to implementation paths"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.Ecosystem", "AgentJidoWeb.JidoEcosystemLive"],
  source_files: [
    "lib/agent_jido/ecosystem.ex",
    "lib/agent_jido_web/live/jido_ecosystem_live.ex",
    "marketing/content-outline.md"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["features/overview"],
  related: [
    "ecosystem/package-matrix",
    "ecosystem/package-selection-by-use-case",
    "build/quickstarts-by-persona",
    "build/reference-architectures"
  ],
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai", "req_llm", "agent_jido"],
  destination_route: "/ecosystem/overview",
  destination_collection: :ecosystem,
  tags: [:ecosystem, :overview, :architecture]
}
---
## Content Brief

Landing content for `/ecosystem` that bridges features into implementation choices.

Cover:

- Layered package model (runtime, intelligence, tools, integrations)
- What is required vs optional for common starting points
- Links to package matrix and adoption path guides

### Validation Criteria

- Ecosystem package list matches `AgentJido.Ecosystem`
- Layer assignments map to public package metadata
- Includes clear CTA paths into Build and Training
