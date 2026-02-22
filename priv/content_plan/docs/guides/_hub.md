%{
  priority: :high,
  status: :outline,
  title: "Guides Hub",
  repos: ["jido"],
  tags: [:docs, :guides, :navigation, :hub],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Navigate how-to guides by problem domain",
   "Find the right guide for current implementation challenge"],
  order: 1,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Section root that organizes how-to guides, patterns, and cookbook recipes by problem domain",
  related: ["docs/guides/testing-agents-and-actions", "docs/guides/retries-backpressure-and-failure-recovery",
   "docs/guides/cookbook/_hub"],
  prompt_overrides: %{
    document_intent: "Create the guides section hub that organizes how-to guides by problem domain.",
    required_sections: ["Overview", "Guide Index", "Cookbook"],
    must_include: ["One-line description of each guide",
     "Cookbook section with links to runnable recipes"],
    must_avoid: ["Duplicating content from individual guides", "Long prose"],
    required_links: ["/docs/guides/testing-agents-and-actions", "/docs/guides/retries-backpressure-and-failure-recovery",
     "/docs/guides/cookbook"],
    min_words: 200,
    max_words: 500,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Section root for Guides. Organizes how-to guides, patterns, and cookbook recipes by problem domain.

### Validation Criteria

- Each guide has a one-line description and link
- Cookbook section is clearly identified as runnable recipes
- Problem-domain grouping helps users find the right guide quickly
