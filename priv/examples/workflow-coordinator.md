%{
  title: "Workflow Coordinator",
  description: "Orchestrate multi-step pipelines with retry boundaries and checkpoint recovery behavior.",
  tags: ["primary", "showcase", "simulated", "core", "l1", "coordination", "workflow"],
  category: :core,
  emoji: "🔄",
  source_files: [
    "lib/agent_jido_web/examples/simulated_showcase_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.SimulatedShowcaseLive",
  difficulty: :beginner,
  status: :live,
  scenario_cluster: :coordination,
  wave: :l1,
  journey_stage: :activation,
  content_intent: :tutorial,
  capability_theme: :coordination_orchestration,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 6
}
---

## What you'll learn

- How to present orchestration patterns with deterministic execution traces
- How to show fault recovery and retry behavior without side effects
- How coordination examples map to `coordination_orchestration`

## Demo note

Workflow graph execution is simulated with deterministic checkpoints and replay events.

