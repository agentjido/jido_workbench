%{
  priority: :high,
  status: :outline,
  title: "Ecosystem Atlas",
  repos: ["agent_jido"],
  tags: [:docs, :contributors, :ecosystem, :ownership],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/contributors/ecosystem-atlas",
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai", "req_llm"],
  learning_outcomes: ["Find the current public package roster and ownership map",
   "Distinguish support label from release state and package purpose"],
  order: 2,
  prerequisites: [],
  purpose: "Contributor-facing public package roster organized by canonical ecosystem categories with smaller atlas facets for ownership, release state, and purpose",
  related: ["docs/contributors/package-support-levels", "docs/contributors/roadmap",
   "ecosystem/overview"],
  prompt_overrides: %{
    document_intent: "Write the Ecosystem Atlas page as a concise contributor-facing package roster.",
    required_sections: ["Core", "AI", "Runtime", "Tools", "Integrations"],
    must_include: ["One compact markdown table per category",
     "Columns for package, support, owner, release, and purpose",
     "Short note that deeper package pages live under `/ecosystem`",
     "Optional secondary subgroup headings derived from controlled Atlas facet metadata"],
    must_avoid: ["Private packages", "Long package-by-package narrative"],
    required_links: ["/ecosystem", "/docs/contributors/package-support-levels",
     "/docs/contributors/roadmap"],
    min_words: 500,
    max_words: 1200,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Contributor-facing package roster for the public Jido ecosystem.

### Validation Criteria

- Includes only public packages
- Groups packages by canonical ecosystem categories with smaller Atlas facets where helpful
- Shows owner handles and release state distinctly from support level
