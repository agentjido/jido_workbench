%{
  title: "Data Storage and pgvector Reference",
  order: 20,
  purpose: "Provide exact schema and configuration reference for embeddings, retrieval data, and vector index operations",
  audience: :advanced,
  content_type: :reference,
  learning_outcomes: [
    "Select durable data models for memory and retrieval",
    "Configure pgvector indexes and query patterns",
    "Prepare vector workloads for production rollout"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentIngest", "AgentJido.ContentIngest.Inventory"],
  source_files: ["lib/agent_jido/content_ingest.ex", "lib/agent_jido/content_ingest/inventory.ex", "config/runtime.exs"],
  status: :draft,
  priority: :high,
  prerequisites: ["reference/configuration"],
  related: ["operate/persistence-memory-and-vector-search", "training/production-readiness"],
  ecosystem_packages: ["agent_jido"],
  tags: [:reference, :data, :pgvector, :embeddings]
}
---
## Content Brief

Reference doc for schemas, indexing, query strategies, and rollout caveats for vector retrieval.

### Validation Criteria

- Includes schema and index examples with explicit tradeoffs
- Includes migration and operational impact notes
- Aligns with persistence guidance in Operate section
