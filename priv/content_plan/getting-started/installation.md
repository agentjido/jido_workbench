%{
  title: "Installation & Setup",
  order: 1,
  purpose: "Get Jido installed and configured in a new or existing Elixir project",
  audience: :beginner,
  content_type: :tutorial,
  learning_outcomes: [
    "Add jido and jido_ai to a mix.exs",
    "Configure required dependencies",
    "Verify installation with a basic IEx session"
  ],
  repos: ["jido", "jido_ai"],
  source_modules: [],
  source_files: ["mix.exs"],
  status: :planned,
  priority: :critical,
  prerequisites: [],
  related: ["first-agent"],
  ecosystem_packages: ["jido", "jido_ai"],
  tags: [:getting_started, :setup]
}
---
## Content Brief

Walk the reader through adding Jido to a fresh `mix new` project. Cover:

- Adding `{:jido, "~> 2.0.0-rc"}` and `{:jido_ai, "~> 2.0.0-rc"}` to deps
- Running `mix deps.get`
- Basic config entries needed (if any)
- Quick smoke test in IEx: `Jido.Agent` module is available

### Validation Criteria
- All version numbers must match current published Hex versions
- `mix deps.get` must succeed with the listed deps
