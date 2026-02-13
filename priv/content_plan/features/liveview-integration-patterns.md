%{
  title: "LiveView Integration Patterns",
  order: 50,
  purpose: "Track UI integration capabilities where LiveView interactions map to explicit agent commands",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Explain command-driven UI interaction patterns",
    "Map immutable state transitions into reactive rendering",
    "Expose agent behavior clearly to end users"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJidoWeb.JidoFeaturesLive", "AgentJidoWeb.JidoTrainingModuleLive"],
  source_files: ["lib/agent_jido_web/live/jido_features_live.ex", "lib/agent_jido_web/live/jido_training_module_live.ex", "priv/training/liveview-integration.md"],
  status: :published,
  priority: :high,
  prerequisites: ["features/directives-and-scheduling"],
  related: ["training/liveview-integration", "build/counter-agent", "operate/testing-agents-and-actions"],
  ecosystem_packages: ["agent_jido", "jido"],
  tags: [:features, :liveview, :integration]
}
---
## Content Brief

Feature entry covering deterministic UI integration and interaction clarity.
