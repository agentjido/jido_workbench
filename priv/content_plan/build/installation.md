%{
  title: "Installation and Setup",
  order: 10,
  purpose: "Get Jido installed and validated in a new or existing Elixir project with a clean production-safe baseline",
  audience: :beginner,
  content_type: :tutorial,
  learning_outcomes: [
    "Add core Jido dependencies to mix.exs",
    "Configure runtime secrets and provider settings safely",
    "Run a smoke test proving the local environment is ready"
  ],
  repos: ["jido", "jido_ai", "agent_jido"],
  source_modules: ["AgentJido.Application"],
  source_files: ["mix.exs", "config/runtime.exs", "config/config.exs"],
  status: :review,
  priority: :critical,
  prerequisites: [],
  related: [
    "build/first-agent",
    "docs/key-concepts",
    "docs/configuration",
    "training/agent-fundamentals",
    "build/quickstarts-by-persona"
  ],
  ecosystem_packages: ["jido", "jido_ai", "agent_jido"],
  destination_route: "/build/installation",
  destination_collection: :pages,
  tags: [:build, :setup, :getting_started]
}
---
## Content Brief

Setup guide for first-time builders and pilot teams.

Cover:

- Dependency installation and version strategy
- Required environment variables and runtime config separation
- Verification steps for local success in IEx and Phoenix app context
- Common setup failures and quick fixes

### Validation Criteria

- Version examples match currently supported package releases
- Runtime secret handling references `config/runtime.exs` conventions
- Ends with next-step links to `build/first-agent` and persona quickstarts
