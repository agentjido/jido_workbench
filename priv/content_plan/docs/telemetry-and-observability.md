%{
  title: "Telemetry and Observability Reference",
  order: 30,
  purpose: "Central reference for telemetry events, metrics, dimensions, and alerting strategy",
  audience: :advanced,
  content_type: :reference,
  learning_outcomes: [
    "Find key telemetry events and metadata fields",
    "Define dashboards and alerts for runtime health",
    "Connect observability data to debugging and incident response"
  ],
  repos: ["agent_jido", "jido_live_dashboard", "jido"],
  source_modules: ["AgentJidoWeb.Telemetry", "JidoLiveDashboard"],
  source_files: ["lib/agent_jido_web/telemetry.ex", "lib/agent_jido/application.ex", "config/runtime.exs"],
  status: :draft,
  priority: :high,
  prerequisites: ["docs/configuration", "docs/agent-server"],
  related: [
    "docs/retries-backpressure-and-failure-recovery",
    "docs/troubleshooting-and-debugging-playbook",
    "features/operations-observability",
    "docs/incident-playbooks"
  ],
  ecosystem_packages: ["agent_jido", "jido_live_dashboard", "jido"],
  destination_route: "/docs/telemetry-and-observability",
  destination_collection: :pages,
  tags: [:reference, :telemetry, :observability, :operations]
}
---
## Content Brief

Reference table for events, labels, sampling concerns, and alert threshold baselines.

### Validation Criteria

- Event names and metadata fields match instrumentation source
- Dashboard and alert examples map to concrete failure symptoms
- Includes links to operational runbooks
