%{
  title: "Testing Agents and Actions",
  order: 50,
  purpose: "Teach deterministic testing strategies across actions, directives, and UI integrations",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Unit test action contracts and validation boundaries",
    "Test directive outputs without sleep-based assertions",
    "Build integration tests for command-driven LiveView flows"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJido.Demos.CounterAgent", "AgentJido.Demos.DemandTrackerAgent"],
  source_files: [
    "test/agent_jido/demos/counter_agent_test.exs",
    "test/agent_jido/demos/demand_tracker_agent_test.exs",
    "test/agent_jido_web/live/jido_training_module_live_test.exs",
    "test/support/conn_case.ex"
  ],
  status: :draft,
  priority: :high,
  prerequisites: ["docs/actions", "docs/agents", "training/liveview-integration"],
  related: [
    "operate/troubleshooting-and-debugging-playbook",
    "build/counter-agent",
    "build/demand-tracker-agent",
    "operate/production-readiness-checklist"
  ],
  ecosystem_packages: ["agent_jido", "jido"],
  tags: [:operate, :testing, :quality, :liveview]
}
---
## Content Brief

Testing strategy from isolated action tests to workflow and UI integration reliability tests.

### Validation Criteria

- Includes deterministic schedule/directive testing patterns
- Covers state transition isolation from side effects
- Includes at least one end-to-end integration example
