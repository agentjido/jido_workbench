%{
  title: "Incident Playbooks",
  order: 100,
  purpose: "Standardize incident response procedures for common high-impact runtime failure scenarios",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Respond quickly to common incident classes",
    "Use predefined mitigation and rollback paths",
    "Run post-incident reviews that improve reliability over time"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJidoWeb.Telemetry", "Jido.AgentServer"],
  source_files: ["lib/agent_jido_web/telemetry.ex", "lib/jido/agent_server.ex", "marketing/content-governance.md"],
  status: :outline,
  priority: :high,
  prerequisites: ["operate/retries-backpressure-and-failure-recovery", "operate/troubleshooting-and-debugging-playbook"],
  related: [
    "operate/production-readiness-checklist",
    "operate/mixed-stack-runbooks",
    "community/adoption-playbooks"
  ],
  ecosystem_packages: ["jido", "agent_jido"],
  tags: [:operate, :incidents, :runbooks, :reliability]
}
---
## Content Brief

Playbooks for latency spikes, queue saturation, dependency outages, and invalid deployment scenarios.

### Validation Criteria

- Includes incident class taxonomy with trigger thresholds
- Includes mitigation sequence and rollback decision points
- Includes post-incident learning loop requirements
