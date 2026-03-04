%{
  title: "Jido.AI Operational Agents Pack",
  description: "Operational workflows for API smoke tests, GitHub issue triage, and release notes synthesis.",
  tags: ["primary", "showcase", "simulated", "ai", "l2", "ops-governance", "jido_ai", "operations"],
  category: :ai,
  emoji: "🛠",
  related_resources: [
    %{
      path: "/docs/learn/multi-agent-orchestration",
      kind: "Tutorial",
      description: "Operational orchestration and specialization patterns.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "api smoke test agent",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/agents/api_smoke_test_agent.ex",
      kind: "Source",
      description: "ReAct-driven API endpoint testing and debugging."
    },
    %{
      type: :external,
      label: "issue triage agent",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/agents/issue_triage_agent.ex",
      kind: "Source",
      description: "Secure token injection pattern and safe GitHub operations."
    },
    %{
      type: :external,
      label: "release notes agent",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/agents/release_notes_agent.ex",
      kind: "Source",
      description: "Graph-of-Thoughts synthesis for release note generation."
    }
  ],
  source_files: [
    "lib/agent_jido_web/examples/simulated_showcase_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.SimulatedShowcaseLive",
  difficulty: :advanced,
  status: :live,
  scenario_cluster: :ops_governance,
  wave: :l2,
  journey_stage: :operationalization,
  content_intent: :case_study,
  capability_theme: :operations_observability,
  evidence_surface: :runnable_example,
  demo_mode: :simulated,
  sort_order: 26
}
---

## What you'll learn

- How operational agents combine tool-use and safety controls
- How secure context injection patterns keep credentials out of model context
- How to package practical operations workflows into reproducible demos

## Included workflows

- API smoke testing
- GitHub issue triage
- Release notes synthesis

## Demo note

This page simulates operational traces and explicitly avoids live write operations or external API calls.
