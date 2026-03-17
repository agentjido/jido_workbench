%{
  priority: :high,
  status: :outline,
  title: "Contributors Hub",
  repos: ["jido", "agent_jido"],
  tags: [:docs, :contributors, :navigation, :hub],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/contributors",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Find the canonical ecosystem-level contribution standards",
   "Identify which contributor page answers package ownership, support, quality, roadmap, or governance questions"],
  order: 1,
  prerequisites: [],
  purpose: "Section root organizing contributor-facing policy, package ownership, roadmap, and shared ecosystem workflows",
  related: ["docs/contributors/ecosystem-atlas", "docs/contributors/package-support-levels",
   "docs/contributors/package-quality-standards", "docs/contributors/roadmap",
   "docs/contributors/contributing", "docs/contributors/governance-and-team"],
  prompt_overrides: %{
    document_intent: "Create the contributors section hub that routes maintainers and outside contributors to the canonical ecosystem handbook pages.",
    required_sections: ["Section Contents", "Common Entry Points"],
    must_include: ["Clear distinction between `/community` and `/docs/contributors`",
     "One-line description of each contributor page"],
    must_avoid: ["Duplicating the full content of child pages", "Long prose"],
    required_links: ["/docs/contributors/ecosystem-atlas", "/docs/contributors/package-support-levels",
     "/docs/contributors/package-quality-standards", "/docs/contributors/roadmap",
     "/docs/contributors/contributing", "/docs/contributors/governance-and-team", "/community"],
    min_words: 150,
    max_words: 450,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Section root for Contributors. Organizes canonical contributor policy, ownership, roadmap, and ecosystem package standards.

### Validation Criteria

- Makes it obvious this is the contributor-facing handbook
- Distinguishes `/community` from `/docs/contributors`
- Links directly to all six contributor child pages
