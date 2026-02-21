%{
  priority: :critical,
  status: :draft,
  title: "Agent Runtime (AgentServer)",
  repos: ["jido"],
  tags: [:operate, :runtime, :otp, :supervision, :hub_concepts, :format_livebook, :wave_2],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/concepts/agent-runtime",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Start and manage AgentServer processes", "Understand sync and async signal handling semantics",
   "Reason about directive drain behavior and runtime controls"],
  order: 100,
  prerequisites: ["docs/agents", "docs/signals", "docs/directives"],
  purpose: "Explain how to run and supervise agents in production using the OTP-backed runtime",
  related: ["build/multi-agent-workflows", "docs/long-running-agent-workflows",
   "docs/persistence-memory-and-vector-search", "docs/retries-backpressure-and-failure-recovery", "docs/plugins",
   "docs/telemetry-and-observability"],
  source_files: ["lib/jido/agent_server.ex"],
  source_modules: ["Jido.AgentServer"]
}
---
## Content Brief

Operational deep dive for AgentServer lifecycle, flow control, and observability hooks.

### Validation Criteria

- Public API references match source behavior
- Includes clear call/cast tradeoffs and usage guidance
- Links directly into runbook and failure-recovery content
