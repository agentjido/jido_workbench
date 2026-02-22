%{
  priority: :critical,
  status: :review,
  title: "Installation and Setup",
  repos: ["jido", "jido_ai", "agent_jido"],
  tags: [:docs, :learn, :setup, :getting_started, :wave_1],
  audience: :beginner,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/installation",
  legacy_paths: ["/build/installation"],
  ecosystem_packages: ["jido", "jido_ai", "agent_jido"],
  learning_outcomes: ["Add core Jido dependencies to mix.exs",
   "Configure runtime secrets and provider settings safely",
   "Run a smoke test proving the local environment is ready"],
  order: 10,
  prerequisites: [],
  purpose: "Get Jido installed and validated in a new or existing Elixir project with a clean production-safe baseline",
  related: ["docs/learn/first-agent", "docs/concepts/key-concepts", "docs/reference/configuration",
   "docs/learn/agent-fundamentals", "docs/learn/quickstarts-by-persona"],
  source_files: ["mix.exs", "config/runtime.exs", "config/config.exs"],
  source_modules: ["AgentJido.Application"],
  prompt_overrides: %{
    document_intent: "Write a zero-to-running setup guide for first-time Jido users.",
    required_sections: ["Prerequisites", "Add Dependencies", "Configure Runtime", "Verify Installation"],
    must_include: ["Dependency installation and version strategy",
     "Required environment variables and runtime config separation",
     "Verification steps for local success in IEx and Phoenix app context",
     "Common setup failures and quick fixes"],
    must_avoid: ["Building a full agent — that's the next guide"],
    required_links: ["/docs/learn/first-agent", "/docs/learn/quickstarts-by-persona",
     "/docs/reference/configuration"],
    min_words: 500,
    max_words: 1_000,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
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
- Ends with next-step links to first-agent and persona quickstarts
