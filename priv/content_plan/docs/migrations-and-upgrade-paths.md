%{
  priority: :high,
  status: :outline,
  title: "Migrations and Upgrade Paths",
  repos: ["agent_jido", "jido", "jido_ai"],
  tags: [:reference, :migrations, :upgrades, :release, :hub_reference, :format_markdown, :wave_3],
  audience: :advanced,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/migrations-and-upgrade-paths",
  ecosystem_packages: ["agent_jido", "jido", "jido_ai"],
  learning_outcomes: ["Plan dependency upgrades with rollback safety",
   "Identify API or behavior changes that affect runtime", "Validate migration readiness in staging before production"],
  order: 300,
  prerequisites: ["docs/configuration", "docs/production-readiness-checklist"],
  purpose: "Help teams upgrade dependencies and runtime behavior safely across versions",
  related: ["docs/long-running-agent-workflows", "docs/mixed-stack-runbooks", "training/production-readiness"],
  source_files: ["lib/agent_jido/release.ex", "entrypoint", "config/runtime.exs", "mix.lock"],
  source_modules: ["AgentJido.Release"]
}
---
## Content Brief

Upgrade reference for dependency changes, runtime config drift, and release sequencing.

### Validation Criteria

- Includes preflight and rollback checklists
- Includes compatibility notes for key package boundaries
- Includes mixed-stack deployment considerations
