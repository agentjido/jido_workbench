%{
  priority: :high,
  status: :draft,
  title: "Telemetry and Observability Reference",
  related: ["docs/retries-backpressure-and-failure-recovery", "docs/troubleshooting-and-debugging-playbook",
   "features/operations-observability", "docs/incident-playbooks", "training/production-readiness"],
  repos: ["agent_jido", "jido_live_dashboard", "jido"],
  tags: [:reference, :telemetry, :observability, :operations, :hub_reference, :format_markdown, :wave_2],
  audience: :advanced,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/telemetry-and-observability",
  ecosystem_packages: ["agent_jido", "jido_live_dashboard", "jido"],
  learning_outcomes: ["Find key telemetry events and metadata fields",
   "Define dashboards and alerts for runtime health", "Connect observability data to debugging and incident response"],
  order: 280,
  prerequisites: ["docs/configuration", "docs/agent-server"],
  purpose: "Central reference for telemetry events, metrics, dimensions, and alerting strategy",
  source_files: ["lib/agent_jido_web/telemetry.ex", "lib/agent_jido/application.ex", "config/runtime.exs"],
  source_modules: ["AgentJidoWeb.Telemetry", "JidoLiveDashboard"]
}
---
## Content Brief

Reference table for events, labels, sampling concerns, and alert threshold baselines.

### Validation Criteria

- Event names and metadata fields match instrumentation source
- Dashboard and alert examples map to concrete failure symptoms
- Includes links to operational runbooks
