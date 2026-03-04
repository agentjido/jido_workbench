%{
  title: "Jido.AI Weather Reasoning Strategy Suite",
  description: "Side-by-side strategy showcase across ReAct, CoD, AoT, CoT, ToT, GoT, TRM, and Adaptive weather agents.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "weather", "reasoning", "jido_ai"],
  category: :ai,
  emoji: "🧠",
  related_resources: [
    %{
      path: "/docs/learn/reasoning-strategies-compared",
      kind: "Concept",
      description: "Detailed strategy tradeoff guide and examples.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "weather strategy overview module",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/weather/overview.ex",
      kind: "Source",
      description: "Upstream strategy-to-module mapping and CLI examples."
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
  content_intent: :decision_brief,
  capability_theme: :ai_intelligence,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 25
}
---

## What you'll learn

- How one scenario differs across eight reasoning strategies
- How to evaluate strategy tradeoffs for output shape, latency, and complexity
- How to communicate strategy selection without live provider variance

## Strategy set

ReAct, CoD, AoT, CoT, ToT, GoT, TRM, and Adaptive.

## Demo note

Comparisons on this page are deterministic fixtures for repeatable side-by-side evaluation.
