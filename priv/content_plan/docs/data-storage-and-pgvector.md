%{
  priority: :high,
  status: :draft,
  title: "Data Storage and pgvector Reference",
  repos: ["agent_jido"],
  tags: [:reference, :data, :pgvector, :embeddings, :hub_reference, :format_markdown, :wave_2],
  audience: :advanced,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/data-storage-and-pgvector",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Select durable data models for memory and retrieval",
   "Configure pgvector indexes and query patterns", "Prepare vector workloads for production rollout"],
  order: 290,
  prerequisites: ["docs/configuration"],
  purpose: "Provide exact schema and configuration reference for embeddings, retrieval data, and vector index operations",
  related: ["docs/persistence-memory-and-vector-search", "training/production-readiness"],
  source_files: ["lib/agent_jido/content_ingest.ex", "lib/agent_jido/content_ingest/inventory.ex", "config/runtime.exs"],
  source_modules: ["AgentJido.ContentIngest", "AgentJido.ContentIngest.Inventory"]
}
---
## Content Brief

Reference doc for schemas, indexing, query strategies, and rollout caveats for vector retrieval.

### Validation Criteria

- Includes schema and index examples with explicit tradeoffs
- Includes migration and operational impact notes
- Aligns with persistence guidance in Operate section
