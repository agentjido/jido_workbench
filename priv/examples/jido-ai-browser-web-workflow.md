%{
  title: "Jido.AI Browser Web Workflow",
  description: "Multi-turn browsing workflow showing page read, follow-up extraction, and context carryover.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ai-tool-use", "browser", "jido_ai"],
  category: :ai,
  emoji: "🌍",
  related_resources: [
    %{
      path: "/docs/learn/ai-agent-with-tools",
      kind: "Tutorial",
      description: "Build tool-based agent flows with practical boundaries.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "browser workflow demo script",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/scripts/demo/browser_web_workflow_demo.exs",
      kind: "Source",
      description: "Upstream multi-turn browser workflow sample."
    },
    %{
      type: :external,
      label: "browser agent module",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/agents/browser_agent.ex",
      kind: "Source",
      description: "Tool usage guardrails for read/search/snapshot patterns."
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
  sort_order: 20
}
---

## What you'll learn

- How to structure multi-turn browser interactions around one page context
- How to separate `read_page`, `search_web`, and `snapshot_url` intent usage
- How to provide deterministic browser UX while clearly disclosing simulation mode

## Demo note

The workflow here is fixture-driven and deterministic. It simulates page reads and follow-up reasoning without network calls.
