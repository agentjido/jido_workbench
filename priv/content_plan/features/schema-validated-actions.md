%{
  title: "Schema-Validated Actions",
  order: 20,
  purpose: "Capture the value of schema-based action contracts and fail-fast validation boundaries",
  audience: :beginner,
  content_type: :explanation,
  learning_outcomes: [
    "Understand validation at action boundaries",
    "Connect feature messaging to practical action design",
    "Reduce runtime surprises through explicit contracts"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Action", "AgentJidoWeb.JidoFeaturesLive"],
  source_files: ["lib/agent_jido_web/live/jido_features_live.ex", "priv/training/actions-validation.md", "lib/jido/action.ex"],
  status: :published,
  priority: :high,
  prerequisites: ["features/beam-native-agent-model"],
  related: ["training/actions-validation", "docs/actions", "build/tool-use"],
  ecosystem_packages: ["jido_action", "jido", "agent_jido"],
  tags: [:features, :validation, :actions]
}
---
## Content Brief

Feature inventory entry for schema-validated action behavior and contract safety.
