# Contributing

Thanks for helping improve Jido Workbench.

## Scope and Expectations

This repository powers an internal docs and examples site for the Jido ecosystem.
It is not the public SDK source repository.

The most valuable contributions are:

- Bug reports and bug fixes in this app
- Content corrections and clarity improvements
- Small UX, navigation, and quality-of-life fixes

## Content Edits

Most documentation content lives under `priv/`.

- `priv/content_plan/**`: content briefs and source-of-intent docs
- `priv/pages/**`: served docs pages
- `priv/blog/**`, `priv/examples/**`, `priv/ecosystem/**`: additional published content

Preferred workflow:

1. Update the matching brief in `priv/content_plan/**`.
2. Update the page in `priv/pages/**` so published content stays aligned.

Direct edits to `priv/pages/**` are still welcome, especially for quick fixes. If you skip brief updates, note that in the PR.

## Local Setup

```bash
git clone git@github.com:agentjido/agentjido_xyz.git
cd agentjido_xyz
cp .env.example .env
mix setup
mix phx.server
```

## Before You Open a PR

Run the checks that match your change size:

Content-only changes:

```bash
mix site.link_audit --include-heex
```

Code changes:

```bash
mix format
mix test
```

`mix credo` and `mix quality` are encouraged for larger changes.

## Pull Request Guidelines

1. Create a branch from `main`.
2. Keep PRs scoped and descriptive.
3. Include repro steps for bug fixes, and screenshots for UI/content layout changes when helpful.
4. Reference related issues.

## Questions?

Open a GitHub issue.
