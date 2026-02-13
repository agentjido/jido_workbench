%{
  title: "Directives, Scheduling, and Time-Based Behavior",
  order: 40,
  purpose: "Explain directive-based side effects and schedule loops for delayed and recurring work",
  audience: :intermediate,
  content_type: :tutorial,
  learning_outcomes: [
    "Return directives instead of executing effects inline",
    "Implement safe self-scheduling loops",
    "Stop recurring behavior with explicit state guards"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Agent.Directive", "AgentJido.Training"],
  source_files: ["priv/training/directives-scheduling.md", "lib/agent_jido/training.ex"],
  status: :published,
  priority: :high,
  prerequisites: ["training/signals-routing"],
  related: ["training/liveview-integration", "features/directives-and-scheduling", "docs/directives", "build/demand-tracker-agent"],
  ecosystem_packages: ["jido", "agent_jido"],
  destination_route: "/training/directives-scheduling",
  destination_collection: :training,
  tags: [:training, :directives, :scheduling, :time]
}
---
## Content Brief

Module on declarative side effects and recurring behavior control.

### Validation Criteria

- Covers emit and schedule directives with stop conditions
- Maintains curriculum ordering after signals module
- Links to demand-tracker example and operations guides
