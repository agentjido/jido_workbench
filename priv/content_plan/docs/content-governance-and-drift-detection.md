%{
  priority: :high,
  status: :outline,
  title: "Content Governance and Drift Detection",
  related: ["docs/security-and-governance", "community/adoption-playbooks", "features/executive-brief",
   "ecosystem/package-matrix"],
  repos: ["agent_jido"],
  tags: [:reference, :governance, :content, :operations, :hub_reference, :format_markdown, :wave_3],
  audience: :advanced,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/content-governance-and-drift-detection",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Set up validation gates for strategic and technical content",
   "Detect source drift and route fixes by severity", "Operate a recurring review cadence with clear ownership"],
  order: 320,
  prerequisites: ["docs/architecture-decision-guides"],
  purpose: "Define governance workflows that keep published claims aligned with code and package reality",
  source_files: ["marketing/content-governance.md", "lib/agent_jido/content_ingest/inventory.ex",
   "lib/agent_jido/content_plan.ex"],
  source_modules: ["AgentJido.ContentIngest.Inventory", "AgentJido.ContentPlan"]
}
---
## Content Brief

Reference page for validation pipeline design, finding severity model, and ownership loops.

### Validation Criteria

- Includes governance principles and publish gates from marketing strategy
- Includes severity taxonomy with evidence requirements
- Includes operating cadence and ownership matrix
