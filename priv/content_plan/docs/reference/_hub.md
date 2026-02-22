%{
  priority: :critical,
  status: :outline,
  title: "Reference Hub",
  repos: ["jido", "jido_ai"],
  tags: [:docs, :reference, :navigation, :hub],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference",
  ecosystem_packages: ["jido", "jido_ai"],
  learning_outcomes: ["Navigate API references, configuration docs, and architecture guides",
   "Choose which reference page to consult based on current need"],
  order: 1,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Section root organizing API references, configuration, architecture documentation, and glossary",
  related: ["docs/reference/architecture", "docs/reference/configuration",
   "docs/reference/ai-integration-decision-guide",
   "docs/reference/provider-capability-and-fallback-matrix",
   "docs/reference/architecture-decision-guides",
   "docs/reference/telemetry-and-observability",
   "docs/reference/data-storage-and-pgvector",
   "docs/reference/glossary",
   "docs/reference/migrations-and-upgrade-paths",
   "docs/reference/content-governance-and-drift-detection",
   "docs/reference/packages"],
  prompt_overrides: %{
    document_intent: "Create the reference section hub that organizes API references, config, architecture docs, and glossary.",
    required_sections: ["Overview", "Reference Map", "Quick Links"],
    must_include: ["One-line description of each reference page",
     "Grouping by category: architecture, configuration, AI, operations",
     "Links to package-level API docs"],
    must_avoid: ["Duplicating content from individual reference pages", "Long prose — this is a navigation page"],
    required_links: ["/docs/reference/architecture", "/docs/reference/configuration",
     "/docs/reference/ai-integration-decision-guide",
     "/docs/reference/glossary", "/docs/reference/packages"],
    min_words: 200,
    max_words: 500,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Section root for Reference. Organizes API references, configuration docs, architecture guides, and glossary into a navigable map.

### Validation Criteria

- Each reference page has a one-line description and link
- Pages grouped by category: architecture, configuration, AI integration, operations
- Clear pointers to package-level API documentation
