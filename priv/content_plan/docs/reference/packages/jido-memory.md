%{
  priority: :high,
  status: :planned,
  title: "Package Reference: jido_memory",
  repos: ["jido_memory"],
  tags: [:docs, :reference, :packages, :jido_memory, :memory, :vectors, :embeddings, :pgvector, :persistence],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido-memory",
  ecosystem_packages: ["jido_memory"],
  learning_outcomes: [
    "Understand the purpose of the jido_memory package",
    "Know how to install and configure jido_memory with pgvector",
    "Identify key modules for memory storage, embeddings, and search",
    "Understand how memory integrates with agents for context and recall"
  ],
  order: 90,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido_memory package covering memory persistence, embeddings, and vector search.",
  related: [
    "docs/guides/persistence-memory-and-vector-search",
    "docs/reference/data-storage-and-pgvector",
    "docs/reference/packages/jido"
  ],
  source_modules: ["Jido.Memory"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido_memory package — memory and vector search capabilities for agent persistence, embeddings, and semantic retrieval.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet including pgvector setup",
      "Summary of memory storage, embedding, and vector search modules",
      "Configuration options for database, embeddings, and search",
      "Usage examples showing memory storage and semantic search"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido_memory",
      "GitHub repository",
      "docs/guides/persistence-memory-and-vector-search",
      "docs/reference/data-storage-and-pgvector"
    ],
    min_words: 600,
    max_words: 1200,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference for the `jido_memory` package — memory and vector search capabilities for the Jido ecosystem. Covers memory persistence, embedding generation, pgvector integration, and semantic search to enable agents to store and retrieve contextual information. This package gives agents long-term memory and the ability to perform similarity-based recall.

### Validation Criteria

- Clearly explains the package's role in agent memory and vector search
- Includes a working Mix dependency installation snippet with pgvector setup notes
- Documents key modules for storage, embeddings, and search
- Lists configuration options for database and embedding providers
- Provides at least 3 code examples showing memory storage and semantic search
- Links to the persistence guide and data storage reference
- Does not duplicate full API docs from HexDocs
