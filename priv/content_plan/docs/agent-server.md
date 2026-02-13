%{
  title: "Agent Runtime (AgentServer)",
  order: 10,
  purpose: "Explain how to run and supervise agents in production using the OTP-backed runtime",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Start and manage AgentServer processes",
    "Understand sync and async signal handling semantics",
    "Reason about directive drain behavior and runtime controls"
  ],
  repos: ["jido"],
  source_modules: ["Jido.AgentServer"],
  source_files: ["lib/jido/agent_server.ex"],
  status: :draft,
  priority: :critical,
  prerequisites: ["docs/agents", "docs/signals", "docs/directives"],
  related: [
    "build/multi-agent-workflows",
    "docs/long-running-agent-workflows",
    "docs/persistence-memory-and-vector-search",
    "docs/retries-backpressure-and-failure-recovery",
    "docs/plugins",
    "docs/telemetry-and-observability"
  ],
  ecosystem_packages: ["jido"],
  destination_route: "/docs/agent-server",
  destination_collection: :pages,
  tags: [:operate, :runtime, :otp, :supervision]
}
---
## Content Brief

Operational deep dive for AgentServer lifecycle, flow control, and observability hooks.

### Validation Criteria

- Public API references match source behavior
- Includes clear call/cast tradeoffs and usage guidance
- Links directly into runbook and failure-recovery content
