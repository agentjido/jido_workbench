%{
  title: "Text-to-SQL Analytics",
  description: "Natural language analytics flow that compiles deterministic SQL and result summaries.",
  tags: ["primary", "showcase", "simulated", "ai", "l1", "ai-tool-use", "sql"],
  category: :ai,
  emoji: "📊",
  source_files: [
    "lib/agent_jido_web/examples/simulated_showcase_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.SimulatedShowcaseLive",
  difficulty: :beginner,
  status: :live,
  scenario_cluster: :ai_tool_use,
  wave: :l1,
  journey_stage: :evaluation,
  content_intent: :tutorial,
  capability_theme: :ai_intelligence,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 5
}
---

## What you'll learn

- How to demo NL-to-SQL intent parsing and query generation with fixtures
- How to surface deterministic SQL output and keep the demo reproducible
- How to frame analytics demos without database credentials

## Demo note

The generated SQL and chart payload are deterministic fixture outputs, not live query execution.

