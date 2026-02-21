%{
  priority: :medium,
  status: :outline,
  title: "Architecture Decision Guides",
  repos: ["agent_jido", "jido"],
  tags: [:reference, :architecture, :decision, :hub_reference, :format_markdown, :wave_3],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/reference/architecture-decision-guides",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Evaluate architecture options with explicit tradeoff criteria",
   "Document decisions consistently using reusable templates",
   "Align package and runtime choices with reliability goals"],
  order: 310,
  prerequisites: ["ecosystem/package-matrix", "build/reference-architectures"],
  purpose: "Provide ADR-style decision frameworks for common runtime, integration, and operations tradeoffs",
  related: ["ecosystem/package-selection-by-use-case", "docs/production-readiness-checklist",
   "community/adoption-playbooks"],
  source_files: ["marketing/content-outline.md", "marketing/persona-journeys.md", "lib/agent_jido/ecosystem.ex"],
  source_modules: ["AgentJido.ContentPlan", "AgentJido.Ecosystem"]
}
---
## Content Brief

Decision guide templates for integration boundaries, runtime topology, and operations controls.

### Validation Criteria

- Includes a reusable ADR template and scoring rubric
- Includes examples for at least three recurring decisions
- Links each decision domain to Build and Operate counterparts
