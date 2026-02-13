%{
  title: "Architecture Decision Guides",
  order: 50,
  purpose: "Provide ADR-style decision frameworks for common runtime, integration, and operations tradeoffs",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Evaluate architecture options with explicit tradeoff criteria",
    "Document decisions consistently using reusable templates",
    "Align package and runtime choices with reliability goals"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.ContentPlan", "AgentJido.Ecosystem"],
  source_files: ["marketing/content-outline.md", "marketing/persona-journeys.md", "lib/agent_jido/ecosystem.ex"],
  status: :outline,
  priority: :medium,
  prerequisites: ["ecosystem/package-matrix", "build/reference-architectures"],
  related: ["ecosystem/package-selection-by-use-case", "operate/production-readiness-checklist", "community/adoption-playbooks"],
  ecosystem_packages: ["jido", "agent_jido"],
  tags: [:reference, :architecture, :decision]
}
---
## Content Brief

Decision guide templates for integration boundaries, runtime topology, and operations controls.

### Validation Criteria

- Includes a reusable ADR template and scoring rubric
- Includes examples for at least three recurring decisions
- Links each decision domain to Build and Operate counterparts
