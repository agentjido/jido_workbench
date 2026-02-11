%{
  title: "The Agent Runtime (AgentServer)",
  order: 4,
  purpose: "Running agents in production with the OTP-based AgentServer",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Start and manage AgentServer processes",
    "Send sync and async signals",
    "Understand the directive execution queue",
    "Configure worker pools and scheduling"
  ],
  repos: ["jido"],
  source_modules: ["Jido.AgentServer"],
  source_files: ["lib/jido/agent_server.ex"],
  status: :planned,
  priority: :high,
  prerequisites: ["agents", "signals", "directives"],
  related: ["multi-agent-workflows", "plugins"],
  ecosystem_packages: ["jido"],
  tags: [:guides, :runtime, :otp]
}
---
## Content Brief

The OTP runtime for Jido agents:

- Starting an AgentServer with `start_link/1`
- sync (`call/3`) vs async (`cast/2`) signal processing
- The internal directive drain loop
- Worker pools via Poolboy
- Per-agent cron scheduling
- Telemetry and observability hooks

### Validation Criteria
- All AgentServer public API must match source
- GenServer callback flow must match implementation
