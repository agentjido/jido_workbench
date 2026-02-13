%{
  title: "Composable Ecosystem",
  order: 60,
  purpose: "Describe the value of combining Jido packages incrementally as needs evolve",
  audience: :intermediate,
  content_type: :explanation,
  learning_outcomes: [
    "Identify where each package fits in architecture layers",
    "Explain how teams can adopt packages incrementally",
    "Connect package choices to rollout maturity"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJidoWeb.JidoFeaturesLive", "AgentJido.Ecosystem"],
  source_files: ["lib/agent_jido_web/live/jido_features_live.ex", "lib/agent_jido/ecosystem.ex", "lib/agent_jido_web/live/jido_ecosystem_live.ex"],
  status: :published,
  priority: :medium,
  prerequisites: ["features/beam-native-agent-model"],
  related: ["ecosystem/package-matrix", "features/incremental-adoption", "training/agent-fundamentals"],
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai", "req_llm", "agent_jido"],
  destination_route: "/features/composable-ecosystem",
  destination_collection: :pages,
  tags: [:features, :ecosystem, :architecture]
}
---
## Content Brief

Feature entry for composable package-layer adoption narrative.
