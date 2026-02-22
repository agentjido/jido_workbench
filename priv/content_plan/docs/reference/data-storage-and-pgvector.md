%{
  priority: :high,
  status: :draft,
  title: "Data Storage and pgvector Reference",
  repos: ["jido_memory"],
  tags: [:docs, :reference, :storage, :pgvector, :database, :migrations],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/data-storage-and-pgvector",
  ecosystem_packages: ["jido_memory"],
  learning_outcomes: ["Understand Jido database schema and table structure",
   "Set up pgvector for vector similarity search",
   "Apply index strategies for optimal query performance"],
  order: 70,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Schema reference for Jido database tables, pgvector setup, migration guides, and index strategies",
  related: ["docs/guides/persistence-memory-and-vector-search", "docs/reference/packages/jido-memory"],
  prompt_overrides: %{
    document_intent: "Write the definitive data storage reference covering Jido database schema, pgvector setup, and index strategies.",
    required_sections: ["Database Schema", "pgvector Setup", "Migration Reference", "Index Strategies"],
    must_include: ["Table definitions with column types and constraints",
     "pgvector extension installation and configuration",
     "Migration file reference and execution order",
     "Index strategies: B-tree, GIN, HNSW for vector columns"],
    must_avoid: ["Conceptual explanations of vector search — link to guides section",
     "Full application setup tutorials — link to installation"],
    required_links: ["/docs/guides/persistence-memory-and-vector-search",
     "/docs/reference/packages/jido-memory"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Definitive data storage reference for Jido — database schema, pgvector setup, migration guides, and index strategies.

Cover:
- Database schema: table definitions with column types and constraints
- pgvector extension setup and configuration
- Migration file reference and execution order
- Index strategies for optimal query performance (B-tree, GIN, HNSW)

### Validation Criteria

- Schema definitions match jido_memory source migrations
- pgvector setup instructions are functional and version-appropriate
- Index strategies include performance trade-off guidance
- Links to persistence guide and jido-memory package docs
