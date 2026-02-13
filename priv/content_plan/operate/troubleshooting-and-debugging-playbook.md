%{
  title: "Troubleshooting and Debugging Playbook",
  order: 60,
  purpose: "Provide a practical diagnostic workflow for runtime behavior that diverges from expectations",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Triage failures using logs, telemetry, and state snapshots",
    "Identify routing, scheduling, and validation faults quickly",
    "Use repeatable debugging procedures for on-call teams"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJidoWeb.Telemetry", "AgentJidoWeb.Router"],
  source_files: ["lib/agent_jido_web/telemetry.ex", "lib/agent_jido/application.ex", "lib/agent_jido_web/router.ex", "config/runtime.exs"],
  status: :outline,
  priority: :high,
  prerequisites: ["operate/testing-agents-and-actions", "operate/agent-server"],
  related: ["reference/telemetry-and-observability", "features/production-telemetry", "training/production-readiness", "operate/incident-playbooks"],
  ecosystem_packages: ["agent_jido", "jido"],
  tags: [:operate, :debugging, :observability, :runbooks]
}
---
## Content Brief

Debugging flow that moves from symptom classification to validation, mitigation, and escalation.

### Validation Criteria

- Includes decision tree for common runtime failures
- Includes telemetry checkpoints for hypothesis testing
- Includes rollback/escalation criteria for incident response
