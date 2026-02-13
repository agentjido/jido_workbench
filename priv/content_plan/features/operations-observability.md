%{
  title: "Production Telemetry",
  order: 80,
  purpose: "Capture observability feature coverage for runtime metrics, traces, and alerting workflows",
  audience: :advanced,
  content_type: :reference,
  learning_outcomes: [
    "Identify high-value telemetry signals for agent workloads",
    "Connect observability data to incident response",
    "Use telemetry as a production confidence signal"
  ],
  repos: ["agent_jido", "jido_live_dashboard", "jido"],
  source_modules: ["AgentJidoWeb.Telemetry", "AgentJidoWeb.JidoFeaturesLive"],
  source_files: ["lib/agent_jido_web/live/jido_features_live.ex", "lib/agent_jido_web/telemetry.ex", "priv/training/production-readiness.md"],
  status: :published,
  priority: :critical,
  prerequisites: ["features/reliability-by-architecture"],
  related: ["training/production-readiness", "docs/troubleshooting-and-debugging-playbook", "docs/telemetry-and-observability"],
  ecosystem_packages: ["agent_jido", "jido_live_dashboard", "jido"],
  destination_route: "/features/operations-observability",
  destination_collection: :pages,
  tags: [:features, :telemetry, :observability, :production]
}
---
## Content Brief

Feature entry for instrumentation and telemetry-driven operations confidence.
