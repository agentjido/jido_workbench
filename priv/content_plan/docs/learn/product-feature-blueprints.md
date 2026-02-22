%{
  priority: :medium,
  status: :outline,
  title: "Product Feature Blueprints",
  repos: ["jido", "jido_ai"],
  tags: [:docs, :learn, :build, :blueprints, :product],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/learn/product-feature-blueprints",
  legacy_paths: ["/build/product-feature-blueprints"],
  ecosystem_packages: ["jido", "jido_ai"],
  learning_outcomes: ["Map product feature requirements to agent boundaries and packages",
   "Scope a phase-1 milestone with one user-visible workflow",
   "Define launch gate checklists tied to docs and training assets"],
  order: 62,
  prerequisites: ["docs/learn/reference-architectures"],
  purpose: "Convert product feature requirements into shippable agent-powered milestones with owning boundaries, package sets, and readiness checks",
  related: ["docs/learn/reference-architectures", "docs/learn/quickstarts-by-persona",
   "docs/operations/production-readiness-checklist"],
  source_modules: ["Jido.Agent"],
  prompt_overrides: %{
    document_intent: "Write a blueprint library that maps common product features to agent boundaries, packages, and launch checklists.",
    required_sections: ["How to Use This Page", "Blueprint Format", "Blueprint Library", "Creating Your Own Blueprint"],
    must_include: ["Blueprint template with owner, workflow, non-goals, packages, proof route, readiness checks",
     "At least three concrete blueprints (e.g., conversational assistant, content pipeline, demand tracking)",
     "Phase-1 scoping guidance — limit to one workflow and one reliability objective"],
    must_avoid: ["Deep implementation code — link to build tutorials instead",
     "Vendor or provider-specific feature mapping"],
    required_links: ["/docs/learn/reference-architectures", "/docs/learn/quickstarts-by-persona",
     "/docs/operations/production-readiness-checklist"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 1,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Blueprint library converting product feature requirements into shippable agent-powered milestones with boundaries, packages, and launch checklists.

Cover:
- Blueprint template format
- Concrete blueprints for common product features
- Phase-1 scoping with one workflow and one reliability objective
- Launch gate checklists

### Validation Criteria

- Blueprints match existing published product-feature-blueprints content
- Each blueprint has concrete owner, packages, and proof route
- Phase-1 scoping prevents over-engineering
- Links to reference architectures and production readiness
