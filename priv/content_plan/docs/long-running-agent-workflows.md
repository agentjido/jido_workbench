%{
  priority: :high,
  status: :outline,
  title: "Long-Running Agent Workflows",
  repos: ["jido", "agent_jido"],
  tags: [:operate, :workflows, :recovery, :resilience, :hub_guides, :format_livebook, :wave_2],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/long-running-agent-workflows",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Design resumable workflow state and checkpoints",
   "Set timeout, retry, and compensation boundaries", "Recover cleanly from process and node interruptions"],
  order: 170,
  prerequisites: ["docs/agent-server", "docs/signals", "docs/directives"],
  purpose: "Guide teams through designing durable workflows that run for minutes to days with safe recovery behavior",
  related: ["build/multi-agent-workflows", "build/demand-tracker-agent", "training/directives-scheduling",
   "docs/incident-playbooks"],
  source_files: ["lib/agent_jido/demos/demand/demand_tracker_agent.ex",
   "lib/agent_jido/demos/demand/actions/decay_action.ex", "lib/agent_jido_web/examples/demand_tracker_agent_live.ex",
   "lib/agent_jido/application.ex"],
  source_modules: ["Jido.AgentServer", "Jido.Agent.Directive"]
}
---
## Content Brief

Production patterns for workflow state progression, deferred work, retries, and restart safety.

### Validation Criteria

- Includes explicit timeout/retry examples
- Covers idempotency requirements for step handlers
- Documents behavior after restart and partial completion
