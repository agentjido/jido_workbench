%{
  priority: :high,
  status: :draft,
  title: "Persistence, Memory, and Vector Search",
  repos: ["jido", "jido_memory"],
  tags: [:docs, :guides, :persistence, :memory, :vector_search],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/persistence-memory-and-vector-search",
  ecosystem_packages: ["jido", "jido_memory"],
  learning_outcomes: ["Persist agent state and conversation history",
   "Use jido_memory for semantic retrieval with vector search",
   "Choose between in-memory, Ecto, and pgvector storage backends"],
  order: 30,
  prerequisites: ["docs/concepts/agents"],
  purpose: "Guide for persisting agent state, managing conversation memory, and implementing semantic search with vector embeddings",
  related: ["docs/reference/data-storage-and-pgvector", "docs/reference/packages/jido-memory",
   "docs/guides/long-running-agent-workflows"],
  source_modules: ["Jido.Memory"],
  prompt_overrides: %{
    document_intent: "Write a how-to guide for agent state persistence, conversation memory, and vector-based semantic search.",
    required_sections: ["Storage Strategy Selection", "Agent State Persistence", "Conversation Memory", "Vector Search with pgvector", "Memory Lifecycle"],
    must_include: ["Decision matrix: in-memory vs Ecto vs pgvector",
     "Persisting agent state across restarts",
     "Conversation history management for LLM agents",
     "Embedding generation and similarity search with jido_memory",
     "Memory pruning and lifecycle management"],
    must_avoid: ["Ecto schema tutorial basics — assume reader knows Ecto",
     "LLM provider configuration — link to reference"],
    required_links: ["/docs/reference/data-storage-and-pgvector",
     "/docs/reference/packages/jido-memory",
     "/docs/guides/long-running-agent-workflows"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

How-to guide for persisting agent state, managing conversation memory, and implementing semantic search with vector embeddings.

Cover:
- Storage strategy selection: in-memory, Ecto, pgvector
- Agent state persistence across restarts
- Conversation history for LLM agents
- Vector search with jido_memory and pgvector

### Validation Criteria

- Storage decision matrix has clear criteria
- Persistence patterns work with current Jido agent lifecycle
- Vector search examples use jido_memory API accurately
- Links to data-storage reference for schema details
