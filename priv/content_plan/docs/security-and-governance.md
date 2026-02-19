%{
  title: "Security and Governance",
  order: 80,
  purpose: "Establish guardrails for tool permissions, policy controls, and auditable operations",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Define policy boundaries for tool execution and external calls",
    "Implement governance checks for deployment and upgrades",
    "Create auditable control mappings for compliance workflows"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.ContentPlan", "Jido.Agent.Directive"],
  source_files: ["marketing/content-governance.md", "config/runtime.exs", "lib/agent_jido/application.ex"],
  status: :outline,
  priority: :high,
  prerequisites: ["docs/production-readiness-checklist"],
  related: [
    "docs/mixed-stack-runbooks",
    "docs/configuration",
    "docs/content-governance-and-drift-detection",
    "training/manager-roadmap"
  ],
  ecosystem_packages: ["jido", "agent_jido"],
  destination_route: "/docs/reference/security-and-governance",
  destination_collection: :pages,
  tags: [:operate, :security, :governance, :compliance]
}
---
## Content Brief

Operational governance guide covering permissioning, policy checks, and accountability workflows.

### Validation Criteria

- Includes policy examples for tool and network boundaries
- Includes ownership matrix for governance controls
- Includes audit trail requirements and escalation paths
