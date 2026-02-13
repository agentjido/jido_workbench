%{
  title: "Mixed-Stack Integration",
  order: 100,
  purpose: "Show non-Elixir teams how to adopt Jido as a bounded runtime service without full-stack migration",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Define service boundaries between Jido and existing platforms",
    "Integrate via APIs and event contracts safely",
    "Plan phased expansion based on measurable reliability gains"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJidoWeb.Router", "Jido.Signal"],
  source_files: [
    "marketing/persona-journeys.md",
    "lib/agent_jido_web/router.ex",
    "config/runtime.exs"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["why/beam-for-ai-builders", "build/installation"],
  related: [
    "build/reference-architectures",
    "operate/mixed-stack-runbooks",
    "reference/migrations-and-upgrade-paths"
  ],
  ecosystem_packages: ["jido", "jido_signal", "agent_jido"],
  tags: [:build, :mixed_stack, :integration, :adoption]
}
---
## Content Brief

Integration playbook for Python/TS/JVM/.NET frontends and services calling Jido-managed workflows.

### Validation Criteria

- Includes one API-first and one event-first boundary pattern
- Includes rollout/rollback strategy for bounded pilot deployment
- Includes security and observability prerequisites before expansion
