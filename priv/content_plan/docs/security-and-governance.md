%{
  priority: :high,
  status: :outline,
  title: "Security and Governance",
  repos: ["agent_jido", "jido"],
  tags: [:operate, :security, :governance, :compliance, :hub_operations, :format_markdown, :wave_1],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/operations/security-and-governance",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Define policy boundaries for tool execution and external calls",
   "Implement governance checks for deployment and upgrades",
   "Create auditable control mappings for compliance workflows"],
  order: 360,
  prerequisites: ["docs/production-readiness-checklist"],
  purpose: "Establish guardrails for tool permissions, policy controls, and auditable operations",
  related: ["docs/mixed-stack-runbooks", "docs/configuration", "docs/content-governance-and-drift-detection",
   "training/manager-roadmap"],
  source_files: ["marketing/content-governance.md", "config/runtime.exs", "lib/agent_jido/application.ex"],
  source_modules: ["AgentJido.ContentPlan", "Jido.Agent.Directive"]
}
---
## Content Brief

Operational governance guide covering permissioning, policy checks, and accountability workflows.

### Validation Criteria

- Includes policy examples for tool and network boundaries
- Includes ownership matrix for governance controls
- Includes audit trail requirements and escalation paths
