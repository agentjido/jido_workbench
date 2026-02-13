%{
  title: "Retries, Backpressure, and Failure Recovery",
  order: 40,
  purpose: "Provide resilience patterns for overloaded or failing agent systems",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Design retry policies without retry storms",
    "Apply practical backpressure controls",
    "Execute recovery runbooks for common outage modes"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.AgentServer", "AgentJidoWeb.Telemetry"],
  source_files: ["lib/agent_jido/application.ex", "lib/agent_jido_web/telemetry.ex", "config/runtime.exs"],
  status: :draft,
  priority: :critical,
  prerequisites: ["docs/agent-server", "docs/directives", "docs/signals"],
  related: [
    "docs/troubleshooting-and-debugging-playbook",
    "docs/telemetry-and-observability",
    "training/production-readiness",
    "docs/incident-playbooks"
  ],
  ecosystem_packages: ["jido", "agent_jido"],
  destination_route: "/docs/retries-backpressure-and-failure-recovery",
  destination_collection: :pages,
  tags: [:operate, :reliability, :backpressure, :retries]
}
---
## Content Brief

Operational playbook for throughput spikes, dependency failures, and partial degradation modes.

### Validation Criteria

- Includes retry budget and circuit-breaker style guidance
- Defines queue/latency indicators for backpressure decisions
- Provides ordered incident recovery sequence for multiple failure modes
