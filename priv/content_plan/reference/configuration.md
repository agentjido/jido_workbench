%{
  title: "Configuration Reference",
  order: 10,
  purpose: "Centralize runtime and compile-time configuration across Jido ecosystem packages",
  audience: :intermediate,
  content_type: :reference,
  learning_outcomes: [
    "Configure Jido core and AI provider settings",
    "Separate runtime secrets from compile-time settings",
    "Apply environment-specific configuration safely"
  ],
  repos: ["jido", "jido_ai", "agent_jido"],
  source_modules: [],
  source_files: ["config/config.exs", "config/runtime.exs"],
  status: :draft,
  priority: :critical,
  prerequisites: ["build/installation"],
  related: [
    "reference/data-storage-and-pgvector",
    "reference/telemetry-and-observability",
    "reference/migrations-and-upgrade-paths",
    "operate/persistence-memory-and-vector-search",
    "operate/security-and-governance"
  ],
  ecosystem_packages: ["jido", "jido_ai", "req_llm", "agent_jido"],
  tags: [:reference, :configuration, :runtime]
}
---
## Content Brief

Unified reference for configuration keys, provider setup, and environment-specific patterns.

### Validation Criteria

- All config keys correspond to real `Application.get_env` or runtime usage
- Provider names and options match supported adapters
- Includes explicit local/staging/production guidance
