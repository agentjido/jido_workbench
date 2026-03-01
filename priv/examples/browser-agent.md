%{
  title: "Browser Agent",
  description: "Navigate, inspect, and interact with web pages using a deterministic jido_browser simulation.",
  tags: ["primary", "showcase", "simulated", "ai", "l1", "ai-tool-use", "browser"],
  category: :ai,
  emoji: "🌐",
  related_resources: [
    %{
      path: "/docs/getting-started/first-llm-agent",
      kind: "Guide",
      description: "Set up your first LLM-powered agent."
    },
    %{
      path: "/docs/learn/ai-agent-with-tools",
      kind: "Tutorial",
      description: "Build a tool-using AI agent loop.",
      include_livebook: true
    },
    %{
      path: "/docs/learn/reasoning-strategies-compared",
      kind: "Concept",
      description: "Compare strategy tradeoffs for AI decision loops.",
      include_livebook: true
    }
  ],
  source_files: [
    "lib/agent_jido_web/examples/simulated_showcase_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.SimulatedShowcaseLive",
  difficulty: :beginner,
  status: :draft,
  scenario_cluster: :ai_tool_use,
  wave: :l1,
  journey_stage: :evaluation,
  content_intent: :tutorial,
  capability_theme: :ai_intelligence,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 1
}
---

## What you'll learn

- How a browser-agent flow can be demonstrated with deterministic fixture output
- How to keep UX smooth without requiring external credentials or network access
- How to disclose simulated behavior clearly in the UI

## Demo note

This demo intentionally runs in **simulated mode**. It does not call real websites or browser tooling at runtime.
