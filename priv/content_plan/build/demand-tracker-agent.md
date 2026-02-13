%{
  title: "Demand Tracker Agent Example",
  order: 40,
  purpose: "Show directive-driven behavior with emitted events, schedule loops, and stop guards in a realistic workflow",
  audience: :intermediate,
  content_type: :tutorial,
  learning_outcomes: [
    "Apply emit and schedule directives in an action flow",
    "Implement safe self-rescheduling behavior with stop conditions",
    "Connect directive-heavy agents to a LiveView interface"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: [
    "AgentJido.Demos.DemandTrackerAgent",
    "AgentJido.Demos.Demand.BoostAction",
    "AgentJido.Demos.Demand.CoolAction",
    "AgentJido.Demos.Demand.DecayAction",
    "AgentJido.Demos.Demand.ToggleAutoDecayAction"
  ],
  source_files: [
    "lib/agent_jido/demos/demand/demand_tracker_agent.ex",
    "lib/agent_jido/demos/demand/actions/boost_action.ex",
    "lib/agent_jido/demos/demand/actions/cool_action.ex",
    "lib/agent_jido/demos/demand/actions/decay_action.ex",
    "lib/agent_jido/demos/demand/actions/toggle_auto_decay_action.ex",
    "lib/agent_jido_web/examples/demand_tracker_agent_live.ex"
  ],
  status: :published,
  priority: :critical,
  prerequisites: ["build/counter-agent", "training/directives-scheduling"],
  related: [
    "docs/directives",
    "docs/signals",
    "docs/long-running-agent-workflows",
    "docs/production-readiness-checklist"
  ],
  ecosystem_packages: ["jido", "agent_jido"],
  destination_route: "/build/demand-tracker-agent",
  destination_collection: :pages,
  tags: [:build, :examples, :directives, :scheduling, :liveview, :reliability]
}
---
## Content Brief

Canonical intermediate example for production-oriented behavior over time.

### Validation Criteria

- Auto-decay lifecycle start/stop logic is explained and reproducible
- Directive semantics are consistent with source behavior
- Includes links to runbooks and failure-recovery guidance
