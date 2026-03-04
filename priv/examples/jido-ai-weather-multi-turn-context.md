%{
  title: "Jido.AI Weather Multi-Turn Context",
  description: "Conversation demo showing city context carryover and resilient retry behavior across turns.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "weather", "jido_ai"],
  category: :ai,
  emoji: "🌦",
  related_resources: [
    %{
      path: "/docs/learn/reasoning-strategies-compared",
      kind: "Concept",
      description: "Reasoning strategy context for weather assistants.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "weather multi-turn demo script",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/scripts/demo/weather_multi_turn_context_demo.exs",
      kind: "Source",
      description: "Upstream script with retry/backoff helpers and semantic checks."
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
  capability_theme: :ai_intelligence,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 21
}
---

## What you'll learn

- How multi-turn prompts preserve location context across follow-ups
- How retry/backoff behavior can be modeled for transient busy responses
- How to validate semantic constraints in weather assistant responses

## Demo note

This demo uses deterministic turn outcomes and retry traces for predictable interaction and testability.
