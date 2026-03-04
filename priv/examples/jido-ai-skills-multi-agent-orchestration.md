%{
  title: "Jido.AI Skills Multi-Agent Orchestration",
  description: "Multi-question orchestration demo combining arithmetic, conversion, and compound skill usage.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "skills", "jido_ai", "multi-agent"],
  category: :ai,
  emoji: "🤝",
  related_resources: [
    %{
      path: "/docs/learn/multi-agent-orchestration",
      kind: "Tutorial",
      description: "Design and coordinate specialist agent behavior.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "skills orchestration demo script",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/scripts/demo/skills_multi_agent_orchestration_demo.exs",
      kind: "Source",
      description: "Three-question orchestration flow with semantic checks."
    }
  ],
  source_files: [
    "lib/agent_jido_web/examples/simulated_showcase_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.SimulatedShowcaseLive",
  difficulty: :advanced,
  status: :live,
  scenario_cluster: :ai_tool_use,
  wave: :l2,
  journey_stage: :evaluation,
  content_intent: :tutorial,
  capability_theme: :coordination_orchestration,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 24
}
---

## What you'll learn

- How one agent flow can route between multiple skills and tools by question class
- How to validate orchestration quality with deterministic semantic assertions
- How to present mixed-skill execution in a compact interactive trace

## Demo note

All question/response outputs on this page are fixture-driven for deterministic behavior.
