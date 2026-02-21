%{
  priority: :critical,
  status: :draft,
  title: "Retries, Backpressure, and Failure Recovery",
  repos: ["jido", "agent_jido"],
  tags: [:operate, :reliability, :backpressure, :retries, :hub_guides, :format_livebook, :wave_3],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/retries-backpressure-and-failure-recovery",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Design retry policies without retry storms", "Apply practical backpressure controls",
   "Execute recovery runbooks for common outage modes"],
  order: 200,
  prerequisites: ["docs/agent-server", "docs/directives", "docs/signals"],
  purpose: "Provide resilience patterns for overloaded or failing agent systems",
  related: ["docs/troubleshooting-and-debugging-playbook", "docs/telemetry-and-observability",
   "training/production-readiness", "docs/incident-playbooks"],
  source_files: ["lib/agent_jido/application.ex", "lib/agent_jido_web/telemetry.ex", "config/runtime.exs"],
  source_modules: ["Jido.AgentServer", "AgentJidoWeb.Telemetry"]
}
---
## Content Brief

Operational playbook for throughput spikes, dependency failures, and partial degradation modes.

### Validation Criteria

- Includes retry budget and circuit-breaker style guidance
- Defines queue/latency indicators for backpressure decisions
- Provides ordered incident recovery sequence for multiple failure modes
