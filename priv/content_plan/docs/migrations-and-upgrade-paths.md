%{
  title: "Migrations and Upgrade Paths",
  order: 40,
  purpose: "Help teams upgrade dependencies and runtime behavior safely across versions",
  audience: :advanced,
  content_type: :reference,
  learning_outcomes: [
    "Plan dependency upgrades with rollback safety",
    "Identify API or behavior changes that affect runtime",
    "Validate migration readiness in staging before production"
  ],
  repos: ["agent_jido", "jido", "jido_ai"],
  source_modules: ["AgentJido.Release"],
  source_files: ["lib/agent_jido/release.ex", "entrypoint", "config/runtime.exs", "mix.lock"],
  status: :outline,
  priority: :high,
  prerequisites: ["docs/configuration", "docs/production-readiness-checklist"],
  related: ["docs/long-running-agent-workflows", "docs/mixed-stack-runbooks", "training/production-readiness"],
  ecosystem_packages: ["agent_jido", "jido", "jido_ai"],
  destination_route: "/docs/migrations-and-upgrade-paths",
  destination_collection: :pages,
  tags: [:reference, :migrations, :upgrades, :release]
}
---
## Content Brief

Upgrade reference for dependency changes, runtime config drift, and release sequencing.

### Validation Criteria

- Includes preflight and rollback checklists
- Includes compatibility notes for key package boundaries
- Includes mixed-stack deployment considerations
