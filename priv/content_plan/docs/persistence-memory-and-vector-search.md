%{
  priority: :critical,
  status: :draft,
  title: "Persistence, Memory, and Vector Search",
  repos: ["agent_jido"],
  tags: [:operate, :persistence, :rag, :pgvector, :hub_guides, :format_livebook, :wave_2],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/persistence-memory-and-vector-search",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Choose what stays in memory versus durable storage", "Model embedding pipelines with pgvector",
   "Plan retention and schema evolution safely"],
  order: 160,
  prerequisites: ["docs/agent-server", "docs/configuration"],
  purpose: "Explain practical persistence architecture for agent state, embeddings, and retrieval workloads",
  related: ["docs/data-storage-and-pgvector", "docs/configuration", "training/production-readiness"],
  source_files: ["lib/agent_jido/content_ingest.ex", "lib/agent_jido/content_ingest/ingestor.ex",
   "lib/agent_jido/content_ingest/inventory.ex", "config/runtime.exs"],
  source_modules: ["AgentJido.ContentIngest", "AgentJido.ContentIngest.Inventory"]
}
---
## Content Brief

Data operations guidance for state persistence, embedding storage, and vector retrieval in production systems.

### Validation Criteria

- Includes schema and index guidance for pgvector workloads
- Covers retention policies and migration impact
- Connects storage choices to incident and rollback scenarios
