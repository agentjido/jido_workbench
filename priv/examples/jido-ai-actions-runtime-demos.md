%{
  title: "Jido.AI Actions Runtime Demos",
  description: "Direct `Jido.Exec.run/3` action demos for LLM, planning, reasoning, retrieval, quota, and tool-calling.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "jido_ai", "actions"],
  category: :ai,
  emoji: "🧰",
  related_resources: [
    %{
      path: "/docs/learn/ai-agent-with-tools",
      kind: "Tutorial",
      description: "Understand tool-calling loops and runtime integration.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "actions demo scripts",
      href: "https://github.com/agentjido/jido_ai/tree/main/lib/examples/scripts/demo",
      kind: "Source",
      description: "Upstream action runtime scripts across action families."
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
  content_intent: :reference,
  capability_theme: :ai_intelligence,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 19
}
---

## What you'll learn

- When to use direct action runtime calls instead of long-lived agent loops
- How the core action families map to practical workflows
- How to demonstrate runtime behavior using deterministic fixtures

## Covered action families

- LLM actions
- Tool calling actions
- Planning actions
- Reasoning actions
- Retrieval actions
- Quota actions

## Demo note

This page replays deterministic traces for each family and does not call external providers.
