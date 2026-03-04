%{
  title: "Runic Structured LLM Branching",
  description: "Two-phase orchestrator that routes into direct, analysis, or safe branch workflows.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "runic", "branching"],
  category: :ai,
  emoji: "🌿",
  related_resources: [
    %{
      path: "/docs/learn/reasoning-strategies-compared",
      kind: "Concept",
      description: "Reasoning patterns for branch-heavy decision paths.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "branching demo source",
      href: "https://github.com/agentjido/jido_runic/blob/main/lib/examples/branching_demo.exs",
      kind: "Source",
      description: "Structured route output and branch execution walkthrough."
    },
    %{
      type: :external,
      label: "branching orchestrator module",
      href: "https://github.com/agentjido/jido_runic/blob/main/lib/examples/branching/llm_branching_orchestrator.ex",
      kind: "Source",
      description: "Route extraction, workflow swap, and phase 2 execution."
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
  capability_theme: :ai_intelligence,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 17
}
---

## What you'll learn

- How phase-1 structured routing output can select a phase-2 DAG
- How route metadata (`route`, `detail_level`, `confidence`) can drive UX and observability
- How to expose all branch outcomes without nondeterministic model behavior

## Route outcomes

- `:direct` -> quick answer branch
- `:analysis` -> plan + synthesis branch
- `:safe` -> fallback response branch

## Demo note

All route decisions and branch traces here are deterministic fixtures designed for repeatable interaction and testing.
