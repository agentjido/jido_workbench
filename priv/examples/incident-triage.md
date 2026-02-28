%{
  title: "Incident Triage",
  description: "Ops copilot pattern for alert clustering, severity assignment, and escalation recommendation.",
  tags: ["primary", "showcase", "simulated", "production", "l1", "ops-governance", "incident"],
  category: :production,
  emoji: "🚨",
  source_files: [
    "lib/agent_jido_web/examples/simulated_showcase_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.SimulatedShowcaseLive",
  difficulty: :beginner,
  status: :live,
  scenario_cluster: :ops_governance,
  wave: :l1,
  journey_stage: :operationalization,
  content_intent: :tutorial,
  capability_theme: :operations_observability,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 4
}
---

## What you'll learn

- How to stage incident workflows into deterministic, explainable steps
- How to model triage decisions and escalation output in a reproducible demo
- How to align operational examples to `operations_observability`

## Demo note

Incident data, clustering, and escalation outcomes are fixture-driven and deterministic.

