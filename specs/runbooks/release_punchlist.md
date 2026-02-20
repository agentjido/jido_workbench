# Website Release Punchlist

Last updated: 2026-02-20

## Purpose

Ship the public site with consistent positioning, working navigation paths, and no critical link/content regressions.

This runbook is the operator checklist for release readiness.

## Launch Scope Assumptions

- Training pages are intentionally hidden for this launch.
- Any existing `/training` or `/training/*` links are release defects unless explicitly accepted as temporary 404 behavior.
- Core positioning is locked from `specs/README.md`:
  - Anchor phrase: `Jido is a runtime for reliable, multi-agent systems.`
  - Hero headline/subhead and top nav labels are fixed for launch.

## Required Hard Gates

All items must be green before release:

1. Positioning parity:
- Home + top-nav entry pages align to the locked anchor language and differentiator.

2. Link integrity:
- Internal links resolve to canonical shipped routes or are intentionally redirected.
- No hidden-scope links are used as primary path CTAs.

3. Content quality:
- No placeholders (`TODO`, `TBD`, `coming soon`, etc.).
- Claims are bounded and proof-backed.
- Section template expectations are met (`specs/templates/*`).

4. Technical quality:
- `mix format --check-formatted`
- `mix credo`
- `mix test`

5. SEO/share baseline:
- OG routes return images for top pages.
- `sitemap.xml` and `feed` endpoints render.

## Execution Order (Homepage Down)

Run this in top-down order so narrative and routing issues are caught early:

1. `/` (home)
- Validate hero copy against locked anchor.
- Validate primary CTA and secondary CTA paths.
- Validate in-page links to Features/Ecosystem/Examples/Docs/Build/Community.

2. `/features` + `/features/*`
- Confirm each page has: clear capability claim, proof reference, next-step CTA.
- Confirm no primary CTA points into hidden routes.

3. `/ecosystem` + `/ecosystem/*`
- Confirm package claims match metadata in `priv/ecosystem/*`.
- Confirm links into docs/examples/build are live.

4. `/examples` + `/examples/*`
- Confirm example detail routes render and key flows are runnable/documented.

5. `/docs` + `/docs/*`
- Confirm canonical docs routes and legacy redirects.
- Confirm references match current module/function names.

6. `/build` + `/build/*`
- Validate setup and implementation steps against current code/repo structure.

7. `/community` + `/community/*`
- Validate adoption/case-study claims and attribution.

8. `/blog`, `/blog/:slug`, `/feed`, `/sitemap.xml`
- Smoke-test list, detail, tag, search, feed, and sitemap.

## Punchlist Matrix Template

Use one row per route/page under review:

| Route | Page purpose | Key claim | Proof link(s) | Primary CTA target | Link audit | Content QA | Owner | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|
| `/` | | | | | ✅ / ⚠️ / ❌ | ✅ / ⚠️ / ❌ | | todo / in-progress / done | |

## Link Audit Workflow

Run internal link checks first (fast), then optional external checks:

```bash
mix site.link_audit --include-heex
mix site.link_audit --include-heex --check-external
```

Notes:

- The audit intentionally ignores global `/*path` catch-all routing so links that only land on 404 are still flagged.
- Use `--allow-prefix /training` only if you intentionally want to suppress hidden-training findings for a specific release cycle.
- `scripts/link_audit.sh` remains available as a compatibility wrapper around `mix site.link_audit`.

## Release-Day Command Set

```bash
mix format --check-formatted
mix credo
mix test
mix phx.routes
mix site.link_audit --include-heex
```

## Severity and Triage

- `P0` (block release): broken primary nav path, broken CTA, broken docs/build entry path, runtime error on public route.
- `P1` (fix before release if feasible): broken secondary links, stale claims, missing proof links.
- `P2` (post-release backlog): polish copy, low-impact UX rough edges.

## Sign-Off Record

Fill before release cut:

- Release date:
- Reviewer:
- Scope:
- Hard-gate status:
- Remaining accepted risks:
- Follow-up tickets:
