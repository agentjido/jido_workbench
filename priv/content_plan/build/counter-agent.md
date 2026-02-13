%{
  title: "Counter Agent Example",
  order: 30,
  purpose: "Demonstrate the foundational Jido pattern with immutable state, validated actions, and signal routing in a live UI",
  audience: :beginner,
  content_type: :tutorial,
  learning_outcomes: [
    "Define a Jido agent with typed schema",
    "Write and compose validated action modules",
    "Route signals to action handlers",
    "Drive a Phoenix LiveView from command results"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: [
    "Jido.Agent",
    "Jido.Action",
    "AgentJido.Demos.CounterAgent",
    "AgentJido.Demos.Counter.IncrementAction",
    "AgentJido.Demos.Counter.DecrementAction",
    "AgentJido.Demos.Counter.ResetAction"
  ],
  source_files: [
    "lib/agent_jido/demos/counter/counter_agent.ex",
    "lib/agent_jido/demos/counter/actions/increment_action.ex",
    "lib/agent_jido/demos/counter/actions/decrement_action.ex",
    "lib/agent_jido/demos/counter/actions/reset_action.ex",
    "lib/agent_jido_web/examples/counter_agent_live.ex"
  ],
  status: :published,
  priority: :critical,
  prerequisites: ["build/first-agent"],
  related: [
    "build/demand-tracker-agent",
    "training/agent-fundamentals",
    "docs/actions",
    "docs/signals",
    "build/product-feature-blueprints"
  ],
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "agent_jido"],
  tags: [:build, :examples, :agents, :actions, :signals, :liveview]
}
---
## Content Brief

Beginner-intermediate proof page used across Awareness, Evaluation, and Activation stages.

### Validation Criteria

- Demo code and explanation match current source modules
- Includes explicit mapping from UI event -> action -> state update
- Includes next-step links into directives, scheduling, and production tracks
