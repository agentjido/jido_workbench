# Contributor Docs Guide

Last updated: 2026-02-28
Audience: contributors editing site docs/content/specs

This guide defines what to keep canonical, what to normalize, and what to streamline.

## Keep

Keep these as canonical (PR-gating) documents:

- `specs/positioning.md` — source of truth for narrative and claims.
- `specs/style-voice.md` — source of truth for voice, terms, and mechanical rules.
- `specs/content-outline.md` — source of truth for IA and page inventory.
- `specs/content-system.md` — source of truth for pipeline and route mapping.
- `specs/content-governance.md` — source of truth for publish gates and quality checks.
- `specs/taxonomy.md` — source of truth for tags/axes/crosswalk.
- `specs/proof.md` — source of truth for claim-to-evidence coverage.
- `specs/templates/*` — source of truth for authoring structure by page type.

Keep these as operational but not narrative policy:

- `specs/runbooks/*` — release/admin/ops procedures.

Keep these as context-only references:

- `specs/competitors/*`
- `specs/brainstorms/*`
- `specs/ontology/*`
- `specs/docs-manifesto.md`

## Normalize

Apply these standards across canonical docs.

### 1) Header fields

Every canonical spec file should include these fields near the top:

- `Status:` (`active`, `draft`, `reference`, `deprecated`)
- `Owner:` (role/team, not just person)
- `Last updated:` (`YYYY-MM-DD`)
- `Scope:` (one sentence)

### 2) Path vocabulary

Use only current path families in canonical docs:

- `priv/pages/*`
- `priv/content_plan/*`
- `priv/ecosystem/*`
- `priv/examples/*`
- `priv/blog/*`

Treat these as retired unless explicitly discussing history:

- `priv/documentation/*`
- `priv/content_plan/why/*`
- `priv/content_plan/operate/*`

### 3) Status language

Use one vocabulary for work state in new or edited canonical entries:

- `planned`
- `in-progress`
- `ready`
- `published`
- `blocked`

Avoid mixed labels like `partial`, emoji state markers, or ad hoc phrases in canonical docs. Existing legacy labels should be normalized as those files are touched.

### 4) Cross-link style

- Use absolute route links for public content (`/docs/...`, `/features/...`).
- Use repo paths for internal references (`priv/...`, `lib/...`).
- If a page moved, update the reference immediately or mark it as historical.

### 5) Single-owner sections

Avoid maintaining the same canonical list in multiple files.

- Persona promises: one owner doc, others link to it.
- IA route inventory: one owner doc, others link to it.
- Proof inventory: one owner doc, others reference it.

## Streamline

### 1) Keep TODOs short and current

`specs/TODO.md` should contain open work only, with clear priority and direct action language.

### 2) Move exploration out of canonical flow

If a doc is exploratory, put it in `specs/brainstorms/` and keep a short pointer from canonical docs when needed.

### 3) Keep canonical docs thin

For canonical files, prefer:

- policy statements
- clear constraints
- links to source details

Avoid large historical narratives and duplicate background sections.

### 4) Enforce update coupling

In PRs that change content routes, structure, or claims, update related canonical docs in the same PR (no deferred doc fixes).

## Contributor PR checklist

Before merging content/docs/spec changes:

1. Confirm file/category placement is correct under `priv/`.
2. Confirm route references match `lib/agent_jido_web/router.ex`.
3. Confirm claim changes are reflected in `specs/proof.md`.
4. Confirm style/term consistency with `specs/style-voice.md`.
5. Run checks:

```bash
mix format --check-formatted
mix credo
mix test
mix phx.routes
```
