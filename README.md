# Jido Workbench

Jido Workbench is a Phoenix LiveView app for Jido ecosystem documentation, examples, and internal learning content.

- Live site: https://jido.run
- Deployment target: Fly.io

This repository is an internal docs/workbench app, not the public SDK source repository for `jido` or `jido_ai`.

## Quick Start

Prerequisites:

- Elixir and Erlang (see `mix.exs`)
- PostgreSQL running locally

```bash
git clone git@github.com:agentjido/agentjido_xyz.git
cd agentjido_xyz
cp .env.example .env
mix setup
mix phx.server
```

Open http://localhost:4000.

## Development Auth

Self-service signup is intentionally disabled.

Bootstrap a local admin account:

```bash
ADMIN_EMAIL=you@example.com ADMIN_PASSWORD='at-least-12-chars' mix run priv/repo/seeds.exs
```

Notes:

- `ADMIN_PASSWORD` is optional. If omitted, log in via magic link.
- With the local mail adapter, open http://localhost:4000/dev/mailbox to get login links.
- `mix setup` already runs seeds, so rerun the seed command any time you want to update/bootstrap your dev account.

## Common Commands

```bash
mix test
mix format
mix credo
mix quality
```

`mix quality` now runs the strict Credo baseline, warnings-as-errors compile, and Dialyzer. The managed `pre_push` hook also runs `mix credo --strict`, `mix test`, and `mix dialyzer`.

## Content Layout

- `priv/content_plan/**` contains content briefs and planning docs.
- `priv/pages/**` contains docs pages served by the site.
- `priv/blog/**`, `priv/examples/**`, and `priv/ecosystem/**` contain other published content.

For content updates, prefer updating the relevant brief in `priv/content_plan/**` and then syncing the corresponding page in `priv/pages/**`. Direct page edits are still fine for quick fixes.

## Link Audit

Run the site link audit:

```bash
mix site.link_audit --include-heex
```

Useful variants:

```bash
# Include external URL checks (slower)
mix site.link_audit --include-heex --check-external

# Temporarily allow known hidden route prefixes
mix site.link_audit --include-heex --allow-prefix /training
```

The audit writes `tmp/link_audit_report.md` by default and exits non-zero on blocking issues.

## Contributing

See `CONTRIBUTING.md`.
