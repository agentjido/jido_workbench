%{
  title: "Persistence, Memory, and Vector Search",
  order: 30,
  purpose: "Explain practical persistence architecture for agent state, embeddings, and retrieval workloads",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Choose what stays in memory versus durable storage",
    "Model embedding pipelines with pgvector",
    "Plan retention and schema evolution safely"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentIngest", "AgentJido.ContentIngest.Inventory"],
  source_files: [
    "lib/agent_jido/content_ingest.ex",
    "lib/agent_jido/content_ingest/ingestor.ex",
    "lib/agent_jido/content_ingest/inventory.ex",
    "config/runtime.exs"
  ],
  status: :draft,
  priority: :critical,
  prerequisites: ["docs/agent-server", "docs/configuration"],
  related: ["docs/data-storage-and-pgvector", "docs/configuration", "training/production-readiness"],
  ecosystem_packages: ["agent_jido"],
  destination_route: "/docs/persistence-memory-and-vector-search",
  destination_collection: :pages,
  tags: [:operate, :persistence, :rag, :pgvector]
}
---
## Content Brief

Data operations guidance for state persistence, embedding storage, and vector retrieval in production systems.

### Validation Criteria

- Includes schema and index guidance for pgvector workloads
- Covers retention policies and migration impact
- Connects storage choices to incident and rollback scenarios
