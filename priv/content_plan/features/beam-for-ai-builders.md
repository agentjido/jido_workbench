%{
  title: "Why BEAM for AI Builders",
  order: 2,
  purpose: "Translate Elixir/OTP advantages into practical outcomes for non-Elixir teams evaluating Jido",
  audience: :intermediate,
  content_type: :explanation,
  learning_outcomes: [
    "Describe process isolation and supervision in practical reliability terms",
    "Map BEAM runtime properties to long-lived agent workload requirements",
    "Evaluate bounded-service adoption paths without full-stack migration"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.AgentServer", "AgentJidoWeb.JidoFeaturesLive"],
  source_files: [
    "marketing/positioning.md",
    "marketing/persona-journeys.md",
    "lib/agent_jido_web/live/jido_features_live.ex"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["features/overview"],
  related: [
    "features/jido-vs-framework-first-stacks",
    "build/mixed-stack-integration",
    "docs/mixed-stack-runbooks",
    "docs/migrations-and-upgrade-paths"
  ],
  ecosystem_packages: ["jido", "agent_jido"],
  destination_route: "/features/beam-for-ai-builders",
  destination_collection: :pages,
  tags: [:features, :beam, :mixed_stack, :evaluation]
}
---
## Content Brief

Outcome-first explainer for Python/TypeScript/JVM evaluators.

Cover:

- Reliability semantics of OTP supervision and isolation
- How Jido can run as a bounded agent service in a polyglot architecture
- Migration-without-rewrite framing and pilot boundaries
- Objection handling for perceived complexity and Elixir adoption risk

### Validation Criteria

- Includes one architecture diagram for bounded-service integration
- Includes one side-by-side comparison table with prototype-first options
- Ends with links to Build and Operate tracks for mixed-stack teams
