%{
  title: "Runic Delegating Orchestrator",
  description: "Parent workflow that delegates selected nodes to child agents for execution.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "coordination", "runic", "multi-agent"],
  category: :ai,
  emoji: "🛰",
  related_resources: [
    %{
      path: "/docs/learn/multi-agent-orchestration",
      kind: "Tutorial",
      description: "Coordination patterns for parent/child agent systems.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "delegating demo source",
      href: "https://github.com/agentjido/jido_runic/blob/main/lib/examples/delegating_demo.exs",
      kind: "Source",
      description: "End-to-end delegating pipeline script."
    },
    %{
      type: :external,
      label: "delegating orchestrator module",
      href: "https://github.com/agentjido/jido_runic/blob/main/lib/examples/delegating/delegating_orchestrator.ex",
      kind: "Source",
      description: "ActionNode executor tags and child handoff flow."
    }
  ],
  source_files: [
    "lib/agent_jido_web/examples/simulated_showcase_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.SimulatedShowcaseLive",
  difficulty: :advanced,
  status: :live,
  scenario_cluster: :coordination,
  wave: :l2,
  journey_stage: :evaluation,
  content_intent: :tutorial,
  capability_theme: :coordination_orchestration,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 18
}
---

## What you'll learn

- How to mix local node execution with delegated child-agent nodes
- How `executor: {:child, tag}` affects workflow dispatch behavior
- How to surface parent/child handoff traces in a deterministic demo UI

## Delegated stages

`DraftArticle` and `EditAndAssemble` are delegated to specialized child workers while early planning nodes run locally.

## Demo note

This page simulates child-agent handoffs and runnable completion signals using fixtures, not live child processes.
