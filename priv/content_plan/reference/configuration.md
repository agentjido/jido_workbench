%{
  title: "Configuration Reference",
  order: 1,
  purpose: "All configuration options across the Jido ecosystem in one place",
  audience: :intermediate,
  content_type: :reference,
  learning_outcomes: [
    "Configure Jido core settings",
    "Configure JidoAI LLM providers",
    "Set up telemetry and observability",
    "Understand environment-specific config patterns"
  ],
  repos: ["jido", "jido_ai"],
  source_modules: [],
  source_files: ["config/config.exs", "config/runtime.exs"],
  status: :planned,
  priority: :medium,
  prerequisites: ["installation"],
  related: [],
  ecosystem_packages: ["jido", "jido_ai"],
  tags: [:reference, :configuration]
}
---
## Content Brief

Unified configuration reference:

- Jido core config options
- JidoAI provider configuration (Anthropic, OpenAI, etc.)
- ReqLLM client configuration
- Telemetry configuration
- Runtime vs compile-time config patterns

### Validation Criteria
- All config keys must exist in source Application.get_env calls
- Provider names must match available adapters
