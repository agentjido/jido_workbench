%{
  title: "Coding Assistant",
  description: "File analysis, patch recommendation, and test guidance shown through a deterministic coding workflow.",
  tags: ["primary", "showcase", "simulated", "ai", "l1", "ai-tool-use", "coding"],
  category: :ai,
  emoji: "💻",
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
  sort_order: 3
}
---

## What you'll learn

- How to represent a coding-agent workflow without remote model dependencies
- How to show step-by-step reasoning artifacts in a predictable UI trace
- How to keep demos production-safe while preserving product narrative

## Demo note

This example replays a fixed execution trace and patch plan. No LLM providers are called.

