%{
  priority: :medium,
  status: :outline,
  title: "Reference Docs Hub",
  related: ["docs/configuration", "docs/telemetry-and-observability", "docs/migrations-and-upgrade-paths",
   "ecosystem/package-matrix"],
  repos: ["agent_jido"],
  tags: [:docs, :reference, :navigation, :hub_reference, :format_markdown, :wave_1],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Find authoritative implementation details quickly",
   "Understand which reference docs are required pre-launch",
   "Use reference content alongside build and operate guidance"],
  order: 40,
  prerequisites: ["docs/overview"],
  purpose: "Route users to exact configuration, telemetry, and migration references",
  source_files: ["priv/content_plan/docs/**/*.md", "marketing/content-outline.md"],
  source_modules: ["AgentJido.ContentPlan"]
}
---
## Content Brief

Reference index for exact semantics and production-critical details.

### Validation Criteria

- Includes explicit "read this before launch" callouts
- Links each reference page to one Build and one Operate page
- Avoids long-form conceptual duplication
