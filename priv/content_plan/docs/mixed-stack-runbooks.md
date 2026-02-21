%{
  priority: :high,
  status: :outline,
  title: "Mixed-Stack Runbooks",
  repos: ["agent_jido"],
  tags: [:operate, :mixed_stack, :runbooks, :incidents, :hub_guides, :format_markdown, :wave_3],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/mixed-stack-runbooks",
  ecosystem_packages: ["agent_jido", "jido"],
  learning_outcomes: ["Operate bounded Jido services within cross-language systems",
   "Define cross-system alerts and incident handoffs", "Coordinate rollback strategies across service boundaries"],
  order: 190,
  prerequisites: ["build/mixed-stack-integration", "docs/production-readiness-checklist"],
  purpose: "Provide runbooks for teams operating Jido services within polyglot production environments",
  related: ["docs/incident-playbooks", "docs/migrations-and-upgrade-paths", "features/beam-for-ai-builders"],
  source_files: ["marketing/persona-journeys.md", "lib/agent_jido_web/router.ex", "lib/agent_jido_web/telemetry.ex"],
  source_modules: ["AgentJidoWeb.Router", "AgentJidoWeb.Telemetry"]
}
---
## Content Brief

Runbook set for cross-stack production support, failure isolation, and service recovery coordination.

### Validation Criteria

- Includes incident handoff templates between platform teams
- Includes SLO and alert ownership guidance across system boundaries
- Includes rollback choreography for mixed-stack deployments
