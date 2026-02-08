# AGENTS.md - Jido Workbench

## Commands
- **Setup:** `mix setup` (deps, assets)
- **Run server:** `mix phx.server` or `iex -S mix phx.server`
- **Test all:** `mix test`
- **Single test:** `mix test test/path/to/test_file.exs:LINE`
- **Format:** `mix format`
- **Lint:** `mix credo`

## Architecture
Phoenix 1.7+ LiveView app showcasing the Jido AI Agent Framework. Deployed to Fly.io.
- `lib/agent_jido/` - Core business logic (blog, documentation, agents, chat)
- `lib/agent_jido_web/` - Phoenix web layer (LiveViews, controllers, components)
- `config/` - Environment configs (dev.exs, test.exs, prod.exs, runtime.exs)
- Uses `jido` and `jido_ai` for AI agent functionality; set `LOCAL_JIDO_DEPS=true` for local dev

## Code Style
- Format with `mix format`; use `@doc`/`@moduledoc` and `@spec` on public functions
- snake_case functions/variables, PascalCase modules
- Keep controllers thin; business logic in contexts under `lib/agent_jido/`
- Use changesets for validation; parameterized Ecto queries to prevent SQL injection
- Never log secrets; use `config/runtime.exs` for runtime secrets
