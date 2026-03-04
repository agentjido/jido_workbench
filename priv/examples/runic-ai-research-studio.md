%{
  title: "Runic AI Research Studio",
  description: "Five-stage Runic workflow for research and writing, presented as an interactive deterministic simulation.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "runic", "workflow"],
  category: :ai,
  emoji: "🧪",
  related_resources: [
    %{
      path: "/docs/learn/ai-agent-with-tools",
      kind: "Tutorial",
      description: "Build tool-using AI agent loops in Jido.",
      include_livebook: true
    },
    %{
      path: "/docs/learn/reasoning-strategies-compared",
      kind: "Concept",
      description: "Understand strategy tradeoffs for multi-step agent behavior.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "jido_runic repository",
      href: "https://github.com/agentjido/jido_runic",
      kind: "Source",
      description: "Upstream Runic integration package and examples."
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
  sort_order: 14
}
---

## What you'll learn

- How a 5-node Runic DAG can drive a complete research-to-article workflow
- How `Jido.Runic.Strategy` can execute the pipeline in one-shot auto mode
- How to present advanced orchestration UX with deterministic fixture traces

## Pipeline topology

```text
PlanQueries -> SimulateSearch -> BuildOutline -> DraftArticle -> EditAndAssemble
```

This example mirrors the Studio auto pipeline from `jido_runic`, but runs in deterministic simulation mode in the site UI.

## Source references

- [studio_demo.exs](https://github.com/agentjido/jido_runic/blob/main/lib/examples/studio_demo.exs)
- [orchestrator_agent.ex](https://github.com/agentjido/jido_runic/blob/main/lib/examples/studio/orchestrator_agent.ex)

## Run command (upstream package)

```bash
mix run lib/examples/studio_demo.exs
```

## Demo note

This page intentionally runs in simulated mode with deterministic fixture output. No live LLM, browser, or network calls are executed.
