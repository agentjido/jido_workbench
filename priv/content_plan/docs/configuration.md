%{
  priority: :critical,
  status: :draft,
  title: "Configuration Reference",
  repos: ["jido", "jido_ai", "agent_jido"],
  tags: [:reference, :configuration, :runtime, :hub_reference, :format_markdown, :wave_1],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/configuration",
  ecosystem_packages: ["jido", "jido_ai", "req_llm", "agent_jido"],
  learning_outcomes: ["Configure Jido core and AI provider settings",
   "Separate runtime secrets from compile-time settings", "Apply environment-specific configuration safely"],
  order: 260,
  prerequisites: ["build/installation"],
  purpose: "Centralize runtime and compile-time configuration across Jido ecosystem packages",
  related: ["docs/data-storage-and-pgvector", "docs/telemetry-and-observability", "docs/migrations-and-upgrade-paths",
   "docs/persistence-memory-and-vector-search", "docs/security-and-governance"],
  source_files: ["config/config.exs", "config/runtime.exs"],
  source_modules: []
}
---
## Content Brief

Unified reference for configuration keys, provider setup, and environment-specific patterns.

### Validation Criteria

- All config keys correspond to real `Application.get_env` or runtime usage
- Provider names and options match supported adapters
- Includes explicit local/staging/production guidance
