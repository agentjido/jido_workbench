%{
  title: "Directives and Scheduling",
  order: 40,
  purpose: "Document time-based orchestration and side-effect control messaging",
  audience: :intermediate,
  content_type: :explanation,
  learning_outcomes: [
    "Explain how directives separate intent from execution",
    "Connect scheduling capabilities to recurring workflows",
    "Understand safe stop conditions for recurring tasks"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Agent.Directive", "AgentJidoWeb.JidoFeaturesLive"],
  source_files: ["lib/agent_jido_web/live/jido_features_live.ex", "priv/training/directives-scheduling.md", "lib/jido/agent/directive.ex"],
  status: :published,
  priority: :high,
  prerequisites: ["features/signal-routing-and-coordination"],
  related: ["training/directives-scheduling", "docs/directives", "build/demand-tracker-agent"],
  ecosystem_packages: ["jido", "agent_jido"],
  tags: [:features, :directives, :schedule]
}
---
## Content Brief

Feature entry for directive execution model and recurring behavior controls.
