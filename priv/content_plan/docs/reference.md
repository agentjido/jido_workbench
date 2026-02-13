%{
  title: "Reference Docs Hub",
  order: 40,
  purpose: "Route users to exact configuration, telemetry, and migration references",
  audience: :intermediate,
  content_type: :reference,
  learning_outcomes: [
    "Find authoritative implementation details quickly",
    "Understand which reference docs are required pre-launch",
    "Use reference content alongside build and operate guidance"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentPlan"],
  source_files: ["priv/content_plan/docs/**/*.md", "marketing/content-outline.md"],
  status: :outline,
  priority: :medium,
  prerequisites: ["docs/overview"],
  related: ["docs/configuration", "docs/telemetry-and-observability", "docs/migrations-and-upgrade-paths"],
  ecosystem_packages: ["agent_jido"],
  destination_route: "/docs/reference",
  destination_collection: :pages,
  tags: [:docs, :reference, :navigation]
}
---
## Content Brief

Reference index for exact semantics and production-critical details.

### Validation Criteria

- Includes explicit "read this before launch" callouts
- Links each reference page to one Build and one Operate page
- Avoids long-form conceptual duplication
