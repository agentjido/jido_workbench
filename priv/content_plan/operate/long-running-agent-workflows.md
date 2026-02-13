%{
  title: "Long-Running Agent Workflows",
  order: 20,
  purpose: "Guide teams through designing durable workflows that run for minutes to days with safe recovery behavior",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Design resumable workflow state and checkpoints",
    "Set timeout, retry, and compensation boundaries",
    "Recover cleanly from process and node interruptions"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.AgentServer", "Jido.Agent.Directive"],
  source_files: [
    "lib/agent_jido/demos/demand/demand_tracker_agent.ex",
    "lib/agent_jido/demos/demand/actions/decay_action.ex",
    "lib/agent_jido_web/examples/demand_tracker_agent_live.ex",
    "lib/agent_jido/application.ex"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["operate/agent-server", "docs/signals", "docs/directives"],
  related: [
    "build/multi-agent-workflows",
    "build/demand-tracker-agent",
    "training/directives-scheduling",
    "operate/incident-playbooks"
  ],
  ecosystem_packages: ["jido", "agent_jido"],
  tags: [:operate, :workflows, :recovery, :resilience]
}
---
## Content Brief

Production patterns for workflow state progression, deferred work, retries, and restart safety.

### Validation Criteria

- Includes explicit timeout/retry examples
- Covers idempotency requirements for step handlers
- Documents behavior after restart and partial completion
