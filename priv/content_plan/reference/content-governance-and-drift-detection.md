%{
  title: "Content Governance and Drift Detection",
  order: 60,
  purpose: "Define governance workflows that keep published claims aligned with code and package reality",
  audience: :advanced,
  content_type: :reference,
  learning_outcomes: [
    "Set up validation gates for strategic and technical content",
    "Detect source drift and route fixes by severity",
    "Operate a recurring review cadence with clear ownership"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentIngest.Inventory", "AgentJido.ContentPlan"],
  source_files: ["marketing/content-governance.md", "lib/agent_jido/content_ingest/inventory.ex", "lib/agent_jido/content_plan.ex"],
  status: :outline,
  priority: :high,
  prerequisites: ["reference/architecture-decision-guides"],
  related: ["operate/security-and-governance", "community/adoption-playbooks", "why/executive-brief"],
  ecosystem_packages: ["agent_jido"],
  tags: [:reference, :governance, :content, :operations]
}
---
## Content Brief

Reference page for validation pipeline design, finding severity model, and ownership loops.

### Validation Criteria

- Includes governance principles and publish gates from marketing strategy
- Includes severity taxonomy with evidence requirements
- Includes operating cadence and ownership matrix
