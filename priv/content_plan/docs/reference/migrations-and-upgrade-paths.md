%{
  priority: :medium,
  status: :outline,
  title: "Migrations and Upgrade Paths",
  repos: ["jido", "jido_ai"],
  tags: [:docs, :reference, :migrations, :upgrades, :versioning, :breaking_changes],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/migrations-and-upgrade-paths",
  ecosystem_packages: ["jido", "jido_ai"],
  learning_outcomes: ["Check version compatibility between Jido ecosystem packages",
   "Identify breaking changes when upgrading versions",
   "Execute migration steps and rollback procedures safely"],
  order: 90,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Version migration guides, breaking changes documentation, upgrade procedures, and rollback strategies",
  related: ["docs/reference/configuration"],
  prompt_overrides: %{
    document_intent: "Write the version migration and upgrade reference covering compatibility, breaking changes, and rollback procedures.",
    required_sections: ["Version Compatibility", "Breaking Changes", "Migration Steps", "Rollback Procedures"],
    must_include: ["Version compatibility matrix across ecosystem packages",
     "Breaking changes listed by version with migration instructions",
     "Step-by-step upgrade procedures",
     "Rollback procedures and safety checks"],
    must_avoid: ["Generic Elixir/Mix upgrade instructions — assume readers know Mix",
     "Speculative future version changes"],
    required_links: ["/docs/reference/configuration"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Version migration and upgrade reference for Jido — version compatibility, breaking changes, upgrade procedures, and rollback strategies.

Cover:
- Version compatibility matrix across jido ecosystem packages
- Breaking changes listed by version with migration instructions
- Step-by-step upgrade procedures
- Rollback procedures and safety checks

### Validation Criteria

- Version compatibility matrix covers all ecosystem packages
- Breaking changes include concrete migration code examples
- Upgrade procedures are ordered and testable
- Rollback procedures cover common failure scenarios
