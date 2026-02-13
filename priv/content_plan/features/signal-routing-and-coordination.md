%{
  title: "Signal Routing and Coordination",
  order: 30,
  purpose: "Track signal-driven coordination messaging and connect it to implementation patterns",
  audience: :intermediate,
  content_type: :explanation,
  learning_outcomes: [
    "Understand event routing as a decoupling mechanism",
    "Identify coordination design patterns supported by signals",
    "Connect routing design to reliability outcomes"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Signal", "AgentJidoWeb.JidoFeaturesLive"],
  source_files: ["lib/agent_jido_web/live/jido_features_live.ex", "priv/training/signals-routing.md", "lib/jido/signal.ex"],
  status: :published,
  priority: :high,
  prerequisites: ["features/schema-validated-actions"],
  related: ["training/signals-routing", "docs/signals", "build/multi-agent-workflows"],
  ecosystem_packages: ["jido_signal", "jido", "agent_jido"],
  tags: [:features, :signals, :coordination]
}
---
## Content Brief

Feature entry for signal-driven communication and coordination capabilities.
