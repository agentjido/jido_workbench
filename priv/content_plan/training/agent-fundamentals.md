%{
  title: "Agent Fundamentals on the BEAM",
  order: 10,
  purpose: "Teach the core Jido mental model: typed state, deterministic transitions, and runtime boundaries",
  audience: :beginner,
  content_type: :tutorial,
  learning_outcomes: [
    "Explain why Jido agents are data-first constructs",
    "Define a typed agent schema with clear constraints",
    "Map signal routes to action modules"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Agent", "AgentJido.Training", "AgentJido.Training.Module"],
  source_files: ["priv/training/agent-fundamentals.md", "lib/agent_jido/training.ex", "lib/agent_jido/training/module.ex"],
  status: :published,
  priority: :high,
  prerequisites: ["build/first-agent"],
  related: ["training/actions-validation", "docs/key-concepts", "features/beam-native-agent-model", "build/counter-agent"],
  ecosystem_packages: ["jido", "agent_jido"],
  destination_route: "/training/agent-fundamentals",
  destination_collection: :training,
  tags: [:training, :agents, :foundation, :beam]
}
---
## Content Brief

Foundational onboarding module for practical runtime understanding.

### Validation Criteria

- Appears first in `/training` ordering
- Includes links into Build example and core concept docs
- Keeps terminology consistent with current source APIs
