%{
  priority: :high,
  status: :outline,
  title: "Troubleshooting and Debugging Playbook",
  repos: ["agent_jido", "jido"],
  tags: [:operate, :debugging, :observability, :runbooks, :hub_guides, :format_livebook, :wave_3],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/troubleshooting-and-debugging-playbook",
  ecosystem_packages: ["agent_jido", "jido"],
  learning_outcomes: ["Triage failures using logs, telemetry, and state snapshots",
   "Identify routing, scheduling, and validation faults quickly",
   "Use repeatable debugging procedures for on-call teams"],
  order: 210,
  prerequisites: ["docs/testing-agents-and-actions", "docs/agent-server"],
  purpose: "Provide a practical diagnostic workflow for runtime behavior that diverges from expectations",
  related: ["docs/telemetry-and-observability", "features/operations-observability", "training/production-readiness",
   "docs/incident-playbooks"],
  source_files: ["lib/agent_jido_web/telemetry.ex", "lib/agent_jido/application.ex", "lib/agent_jido_web/router.ex",
   "config/runtime.exs"],
  source_modules: ["AgentJidoWeb.Telemetry", "AgentJidoWeb.Router"]
}
---
## Content Brief

Debugging flow that moves from symptom classification to validation, mitigation, and escalation.

### Validation Criteria

- Includes decision tree for common runtime failures
- Includes telemetry checkpoints for hypothesis testing
- Includes rollback/escalation criteria for incident response
