%{
  priority: :medium,
  status: :outline,
  title: "Reference Architectures",
  repos: ["jido", "jido_action", "jido_signal", "jido_ai"],
  tags: [:docs, :learn, :build, :architecture, :patterns],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/learn/reference-architectures",
  legacy_paths: ["/build/reference-architectures"],
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai"],
  learning_outcomes: ["Choose a runtime topology that matches team and workload constraints",
   "Map package sets to architecture patterns",
   "Validate architecture choice with a proof-of-concept route"],
  order: 61,
  prerequisites: ["docs/learn/multi-agent-workflows"],
  purpose: "Provide production-proven architecture patterns for common agent system designs with package sets and rollout checklists",
  related: ["docs/learn/mixed-stack-integration", "docs/learn/product-feature-blueprints",
   "docs/reference/architecture", "docs/reference/architecture-decision-guides"],
  source_modules: ["Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write a reference page of production-proven architecture patterns — topologies, package sets, and validation routes.",
    required_sections: ["Single-Service Supervised Runtime", "Orchestration Hub with Workers", "Mixed-Stack Control Plane", "Choosing Your Pattern"],
    must_include: ["Each pattern: required packages, optional packages, first proof route, validation route",
     "Trade-off analysis for each pattern",
     "Architecture diagram for multi-component patterns",
     "Decision criteria for choosing between patterns"],
    must_avoid: ["Implementation details — those belong in build tutorials",
     "Vendor-specific infrastructure choices"],
    required_links: ["/docs/learn/mixed-stack-integration", "/docs/reference/architecture",
     "/docs/learn/counter-agent", "/docs/learn/demand-tracker-agent"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "recommended",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference page of production-proven architecture patterns for Jido agent systems with topologies, package sets, and validation routes.

Cover:
- Single-service supervised runtime pattern
- Orchestration hub with specialized workers
- Mixed-stack control plane on the BEAM
- Decision criteria and trade-off analysis

### Validation Criteria

- Patterns match existing published reference-architectures content
- Package sets are accurate for current ecosystem
- Each pattern has a concrete proof-of-concept route
- Diagrams show component relationships clearly
