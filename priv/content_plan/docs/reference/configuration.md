%{
  priority: :critical,
  status: :draft,
  title: "Configuration Reference",
  repos: ["jido", "jido_ai"],
  tags: [:docs, :reference, :configuration, :environment, :runtime],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/configuration",
  ecosystem_packages: ["jido", "jido_ai"],
  learning_outcomes: ["Configure Jido application settings for development and production",
   "Set up runtime configuration and environment variables",
   "Configure AI provider credentials and settings"],
  order: 40,
  prerequisites: ["docs/learn/installation"],
  purpose: "Complete configuration reference: application config, runtime config, environment variables, and provider configuration",
  related: ["docs/operations/production-readiness-checklist", "docs/learn/installation"],
  prompt_overrides: %{
    document_intent: "Write the definitive configuration reference covering all Jido application, runtime, and provider settings.",
    required_sections: ["Application Configuration", "Runtime Configuration", "Environment Variables", "Provider Configuration"],
    must_include: ["All config keys with types, defaults, and descriptions",
     "Runtime vs compile-time configuration distinction",
     "Environment variable reference table",
     "AI provider credential configuration"],
    must_avoid: ["Tutorial-style setup guides — link to installation page",
     "Production deployment specifics — link to operations section"],
    required_links: ["/docs/operations/production-readiness-checklist",
     "/docs/learn/installation"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Complete configuration reference for Jido — application config, runtime config, environment variables, and provider configuration.

Cover:
- Application configuration keys with types, defaults, and descriptions
- Runtime vs compile-time configuration distinction
- Environment variable reference table
- AI provider credential and settings configuration

### Validation Criteria

- All config keys documented with types, defaults, and descriptions
- Runtime vs compile-time distinction is clear and accurate
- Environment variable table covers all required variables
- Provider configuration matches current jido_ai API
