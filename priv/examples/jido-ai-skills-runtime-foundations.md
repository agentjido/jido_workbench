%{
  title: "Jido.AI Skills Runtime Foundations",
  description: "Skill manifest, loader, registry, and prompt rendering fundamentals in one deterministic walkthrough.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "skills", "jido_ai"],
  category: :ai,
  emoji: "📚",
  related_resources: [
    %{
      path: "/docs/learn/multi-agent-orchestration",
      kind: "Tutorial",
      description: "Skill-aware orchestration patterns for agents.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "skills runtime foundations demo",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/scripts/demo/skills_runtime_foundations_demo.exs",
      kind: "Source",
      description: "Manifest, registry, and prompt rendering checks."
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
  sort_order: 23
}
---

## What you'll learn

- How module and file-backed skills are loaded into one runtime registry
- How manifests and prompt rendering compose into practical agent instructions
- How to communicate skills flow with deterministic, testable output

## Demo note

This walkthrough replays fixed registry/prompt outputs from fixtures to keep behavior stable.
