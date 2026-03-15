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
   "Identify which contributor checklist or policy page applies to a package change"],
  order: 1,
  prerequisites: [],
  purpose: "Section root organizing contributor-facing policy, package standards, and shared ecosystem workflows",
  related: ["docs/contributors/package-quality-standards", "docs/guides/_hub", "docs/reference/_hub"],
  prompt_overrides: %{
    document_intent: "Create the contributors section hub that routes maintainers and outside contributors to canonical ecosystem contribution guidance.",
    required_sections: ["Overview", "Start Here", "What Belongs Here"],
    must_include: ["One-line description of the package quality standards page",
     "Clear statement that this section is the canonical contributor policy surface for the Jido ecosystem"],
    must_avoid: ["Duplicating the full checklist from child pages", "Long prose"],
    required_links: ["/docs/contributors/package-quality-standards", "/docs/guides", "/docs/reference"],
    min_words: 150,
    max_words: 400,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Section root for Contributors. Organizes canonical contributor policy and ecosystem package standards.

### Validation Criteria

- Makes it obvious this is the contributor-facing standards area
- Links directly to package quality standards
- Keeps copy compact and easy to reference from PRs
