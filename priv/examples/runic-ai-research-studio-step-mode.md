%{
  title: "Runic AI Research Studio Step Mode",
  description: "Step-wise execution of the Studio workflow with per-node graph and output introspection.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "runic", "workflow"],
  category: :ai,
  emoji: "🪜",
  related_resources: [
    %{
      path: "/docs/learn/reasoning-strategies-compared",
      kind: "Concept",
      description: "Compare strategy execution styles and observability expectations.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "jido_runic step demo source",
      href: "https://github.com/agentjido/jido_runic/blob/main/lib/examples/studio_step_demo.exs",
      kind: "Source",
      description: "Step-mode demo script from upstream package."
    },
    %{
      type: :external,
      label: "orchestrator run_step implementation",
      href: "https://github.com/agentjido/jido_runic/blob/main/lib/examples/studio/orchestrator_agent.ex",
      kind: "Source",
      description: "Strategy integration for per-step callbacks and annotated graph output."
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
  sort_order: 15
}
---

## What you'll learn

- How to run the Studio DAG in `:step` mode instead of auto-complete mode
- How per-step callbacks expose dispatch/completion, output keys, and graph status
- How to present debugging-grade introspection without requiring provider credentials

## Core idea

Step mode pauses between nodes and emits a structured history snapshot at each transition:

```text
runic.set_mode(:step) -> runic.feed(topic) -> step loop -> runic.step / runic.resume
```

## Upstream command

```bash
mix run lib/examples/studio_step_demo.exs
```

## Demo note

This interactive page uses deterministic fixture traces for step history, graph state, and final summary.
