%{
  title: "BEAM-Native Agent Model",
  order: 10,
  purpose: "Describe the runtime value of BEAM-native isolation and deterministic state transitions for agent systems",
  audience: :beginner,
  content_type: :explanation,
  learning_outcomes: [
    "Explain process isolation benefits for agent workloads",
    "Describe deterministic state transitions as the execution model",
    "Connect runtime semantics to production reliability outcomes"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Agent", "AgentJidoWeb.JidoFeaturesLive"],
  source_files: ["lib/agent_jido_web/live/jido_features_live.ex", "priv/training/agent-fundamentals.md", "marketing/positioning.md"],
  status: :published,
  priority: :high,
  prerequisites: ["features/overview"],
  related: ["training/agent-fundamentals", "docs/key-concepts", "build/first-agent"],
  ecosystem_packages: ["jido", "agent_jido"],
  destination_route: "/features/beam-native-agent-model",
  destination_collection: :pages,
  tags: [:features, :runtime, :beam, :agents]
}
---
## Content Brief

Feature coverage for runtime semantics that differentiate Jido from framework-only approaches.
