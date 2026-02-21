%{
  priority: :high,
  status: :draft,
  title: "Testing Agents and Actions",
  repos: ["agent_jido", "jido"],
  tags: [:operate, :testing, :quality, :liveview, :hub_guides, :format_livebook, :wave_2],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/testing-agents-and-actions",
  ecosystem_packages: ["agent_jido", "jido"],
  learning_outcomes: ["Unit test action contracts and validation boundaries",
   "Test directive outputs without sleep-based assertions", "Build integration tests for command-driven LiveView flows"],
  order: 150,
  prerequisites: ["docs/actions", "docs/agents", "training/liveview-integration"],
  purpose: "Teach deterministic testing strategies across actions, directives, and UI integrations",
  related: ["docs/troubleshooting-and-debugging-playbook", "build/counter-agent", "build/demand-tracker-agent",
   "docs/production-readiness-checklist"],
  source_files: ["test/agent_jido/demos/counter_agent_test.exs", "test/agent_jido/demos/demand_tracker_agent_test.exs",
   "test/agent_jido_web/live/jido_training_module_live_test.exs", "test/support/conn_case.ex"],
  source_modules: ["AgentJido.Demos.CounterAgent", "AgentJido.Demos.DemandTrackerAgent"]
}
---
## Content Brief

Testing strategy from isolated action tests to workflow and UI integration reliability tests.

### Validation Criteria

- Includes deterministic schedule/directive testing patterns
- Covers state transition isolation from side effects
- Includes at least one end-to-end integration example
