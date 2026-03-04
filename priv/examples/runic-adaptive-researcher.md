%{
  title: "Runic Adaptive Researcher",
  description: "Dynamic two-phase workflow that hot-swaps Runic DAG shape based on research richness.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "runic", "adaptive"],
  category: :ai,
  emoji: "🧭",
  related_resources: [
    %{
      path: "/docs/learn/ai-agent-with-tools",
      kind: "Tutorial",
      description: "Build tool-aware workflows and orchestration loops.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "adaptive demo source",
      href: "https://github.com/agentjido/jido_runic/blob/main/lib/examples/adaptive_demo.exs",
      kind: "Source",
      description: "Two-phase adaptive runner script."
    },
    %{
      type: :external,
      label: "adaptive researcher module",
      href: "https://github.com/agentjido/jido_runic/blob/main/lib/examples/adaptive/adaptive_researcher.ex",
      kind: "Source",
      description: "Dynamic phase selection and runic.set_workflow usage."
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
  sort_order: 16
}
---

## What you'll learn

- How to split orchestration into phase 1 research and phase 2 writing
- How to branch between full and slim phase-2 pipelines from phase-1 outputs
- How workflow hot-swapping can be taught with stable, deterministic traces

## Branch behavior

- `full`: `BuildOutline -> DraftArticle -> EditAndAssemble`
- `slim`: `DraftArticle -> EditAndAssemble`

Selection is based on extracted research summary richness in the upstream demo.

## Demo note

This page is intentionally simulated and deterministic. It demonstrates both branch outcomes with fixture-based transitions.
