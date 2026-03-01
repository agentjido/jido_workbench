%{
  title: "Installation and setup",
  description: "Add Jido to a new or existing Elixir project with a production-safe baseline.",
  category: :docs,
  order: 25,
  tags: [:docs, :getting_started, :setup],
  draft: false,
  legacy_paths: ["/docs/learn/installation"],
  learning_outcomes: [
    "Add core Jido dependencies to mix.exs",
    "Configure runtime secrets and provider settings",
    "Verify the installation with a smoke test"
  ]
}
---
## Prerequisites

- Elixir `~> 1.18` and OTP 27+
- An existing Elixir app, or create one with `mix new my_agent_app`
- An API key for an LLM provider if you plan to use AI-backed features

## Add dependencies

Add `jido` and `jido_ai` to `mix.exs`:

```elixir
defp deps do
  [
    {:jido, "~> 2.0"},
    {:jido_ai, "~> 0.2"}
  ]
end
```

Fetch and compile:

```shell
mix deps.get
mix compile
```

## Configure runtime

Runtime configuration belongs in `config/runtime.exs`, not `config/config.exs`. That separation keeps secrets out of compiled artifacts.

Add a minimal provider block for `jido_ai`:

```elixir
import Config

openai_api_key = System.get_env("OPENAI_API_KEY")

if openai_api_key do
  config :jido_ai, :providers,
    openai: [
      api_key: openai_api_key
    ]
end
```

Set the environment variable in your shell or a `.env` file:

```shell
export OPENAI_API_KEY="your-api-key"
```

## Verify installation

Start an IEx session and confirm both applications load:

```shell
iex -S mix
```

```elixir
Application.ensure_all_started(:jido)
Application.ensure_all_started(:jido_ai)
```

Both calls should return `{:ok, _}`. If you see errors, check the troubleshooting section below.

For Phoenix apps, boot the server and confirm the endpoint starts:

```shell
iex -S mix phx.server
```

Visit `http://localhost:4000` or check the logs for the endpoint startup line.

## Common failures

- **`UndefinedFunctionError` for a Jido module** — Run `mix deps.get && mix compile` again, then restart IEx.
- **`{:error, {:jido_ai, ...}}`** — Confirm `jido_ai` is listed in `mix.exs` and the dependency was fetched.
- **`nil` provider config** — Your `OPENAI_API_KEY` is not set in the shell session running `iex -S mix`.
- **Production boot failures** — Ensure `DATABASE_URL` and `SECRET_KEY_BASE` are set in the runtime environment.

## Next steps

- [Your first agent](/docs/getting-started/first-agent)
- [Core concepts](/docs/concepts)
