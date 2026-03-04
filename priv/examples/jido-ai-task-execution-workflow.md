%{
  title: "Jido.AI Task Execution Workflow",
  description: "Tool-driven task lifecycle demo from planning through all-complete state.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "tasks", "jido_ai"],
  category: :ai,
  emoji: "✅",
  related_resources: [
    %{
      path: "/docs/learn/task-planning-and-execution",
      kind: "Tutorial",
      description: "Planning and task execution patterns in Jido systems.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "task execution workflow demo",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/scripts/demo/task_execution_workflow_demo.exs",
      kind: "Source",
      description: "Lifecycle demo using task-list actions."
    }
  ],
  source_files: [
    "lib/agent_jido_web/examples/simulated_showcase_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.SimulatedShowcaseLive",
  difficulty: :intermediate,
  status: :live,
  scenario_cluster: :ai_tool_use,
  wave: :l2,
  journey_stage: :evaluation,
  content_intent: :tutorial,
  capability_theme: :coordination_orchestration,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 22
}
---

## What you'll learn

- How task list tools enforce a deterministic lifecycle (`pending -> in_progress -> done`)
- How to model progression until `all_complete` is reached
- How to observe task state transitions through a compact execution trace

## Demo note

This page simulates task transitions with deterministic fixtures and no external model calls.
