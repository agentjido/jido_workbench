%{
  title: "Mixed-Stack Runbooks",
  order: 90,
  purpose: "Provide runbooks for teams operating Jido services within polyglot production environments",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Operate bounded Jido services within cross-language systems",
    "Define cross-system alerts and incident handoffs",
    "Coordinate rollback strategies across service boundaries"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJidoWeb.Router", "AgentJidoWeb.Telemetry"],
  source_files: ["marketing/persona-journeys.md", "lib/agent_jido_web/router.ex", "lib/agent_jido_web/telemetry.ex"],
  status: :outline,
  priority: :high,
  prerequisites: ["build/mixed-stack-integration", "docs/production-readiness-checklist"],
  related: [
    "docs/incident-playbooks",
    "docs/migrations-and-upgrade-paths",
    "features/beam-for-ai-builders"
  ],
  ecosystem_packages: ["agent_jido", "jido"],
  destination_route: "/docs/mixed-stack-runbooks",
  destination_collection: :pages,
  tags: [:operate, :mixed_stack, :runbooks, :incidents]
}
---
## Content Brief

Runbook set for cross-stack production support, failure isolation, and service recovery coordination.

### Validation Criteria

- Includes incident handoff templates between platform teams
- Includes SLO and alert ownership guidance across system boundaries
- Includes rollback choreography for mixed-stack deployments
