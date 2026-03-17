%{
  priority: :medium,
  status: :outline,
  title: "Governance and Team Structure",
  repos: ["agent_jido"],
  tags: [:docs, :contributors, :governance, :team],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/contributors/governance-and-team",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Understand how Jido makes decisions",
   "Understand how repository ownership and cross-cutting teams fit together"],
  order: 6,
  prerequisites: [],
  purpose: "Contributor-facing governance page describing the BDFL model, repository ownership, and cross-cutting teams",
  related: ["docs/contributors/ecosystem-atlas", "docs/contributors/contributing"],
  prompt_overrides: %{
    document_intent: "Write the governance page as a direct explanation of responsibility and decision making.",
    required_sections: ["Governance Model", "Repository Ownership", "Cross-Cutting Teams", "Inactive Ownership"],
    must_include: ["Mike Hostetler as BDFL",
     "Community team present without a named lead unless updated elsewhere",
     "Documentation lead as TBD unless updated elsewhere"],
    must_avoid: ["Corporate or bureaucratic language", "Hidden ownership assumptions"],
    required_links: ["/docs/contributors/ecosystem-atlas", "/docs/contributors/contributing"],
    min_words: 350,
    max_words: 900,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Contributor-facing governance and responsibility guide.

### Validation Criteria

- Explains the lightweight BDFL model clearly
- Makes repository ownership explicit and links to the atlas
- Covers inactive ownership handling and cross-cutting teams
