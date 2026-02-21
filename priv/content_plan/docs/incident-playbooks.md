%{
  priority: :high,
  status: :outline,
  title: "Incident Playbooks",
  related: ["docs/production-readiness-checklist", "docs/mixed-stack-runbooks", "community/adoption-playbooks",
   "training/production-readiness"],
  repos: ["agent_jido", "jido"],
  tags: [:operate, :incidents, :runbooks, :reliability, :hub_operations, :format_markdown, :wave_2],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/operations/incident-playbooks",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Respond quickly to common incident classes", "Use predefined mitigation and rollback paths",
   "Run post-incident reviews that improve reliability over time"],
  order: 370,
  prerequisites: ["docs/retries-backpressure-and-failure-recovery", "docs/troubleshooting-and-debugging-playbook"],
  purpose: "Standardize incident response procedures for common high-impact runtime failure scenarios",
  source_files: ["lib/agent_jido_web/telemetry.ex", "lib/jido/agent_server.ex", "marketing/content-governance.md"],
  source_modules: ["AgentJidoWeb.Telemetry", "Jido.AgentServer"]
}
---
## Content Brief

Playbooks for latency spikes, queue saturation, dependency outages, and invalid deployment scenarios.

### Validation Criteria

- Includes incident class taxonomy with trigger thresholds
- Includes mitigation sequence and rollback decision points
- Includes post-incident learning loop requirements
