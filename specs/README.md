# Specs Index (Contributor-Facing)

Last updated: 2026-02-28

This folder is the source of truth for site positioning, content rules, and contributor documentation standards.

## Start Here

If you are contributing content or docs, read these in order:

1. `contributor-docs.md`
2. `positioning.md`
3. `style-voice.md`
4. `content-outline.md`
5. `content-system.md`
6. `content-governance.md`
7. `templates/*`

## Document tiers

| Tier | Meaning | Files |
|---|---|---|
| Canonical (normative) | Rules contributors are expected to follow in active PRs | `contributor-docs.md`, `positioning.md`, `style-voice.md`, `content-outline.md`, `content-system.md`, `content-governance.md`, `taxonomy.md`, `proof.md`, `templates/*` |
| Operational | Run/ship procedures for maintainers | `runbooks/*` |
| Planning backlog | Active open items only | `TODO.md`, `topic-briefs-todo.md` |
| Reference and research | Useful context, not normative for PR acceptance | `docs-manifesto.md`, `competitors/*`, `brainstorms/*`, `ontology/*` |

## Current content pipeline snapshot

| Source | Purpose | Rendered |
|---|---|---|
| `priv/pages/*` | Unified site pages (`/docs`, `/features`, `/build`, `/community`, `/training`) | Yes |
| `priv/ecosystem/*` | Ecosystem package pages | Yes |
| `priv/examples/*` | Example pages | Yes |
| `priv/blog/*` | Blog pages/feed | Yes |
| `priv/content_plan/*` | Content briefs and planning metadata | No |

## Contributor rules

- Treat `specs/` as policy and `priv/` as implementation.
- `content-governance.md` includes the canonical ST-CONT-001 publish hard gate and must be enforced before publishing.
- If you change IA, routes, or nav: update `content-outline.md`, `content-system.md`, and `taxonomy.md` in the same PR.
- If you change claims: update `proof.md` and ensure claim discipline still matches `positioning.md`.
- If you change writing mechanics: update `style-voice.md` and confirm templates still align.
- Do not introduce new references to retired paths such as `priv/documentation/*`.

## Folder map

- `competitors/` — competitor briefings and normalized research assets.
- `runbooks/` — operator and release procedures.
- `templates/` — authoring templates for page types.
- `brainstorms/` — exploratory notes and ideation artifacts.
- `audits/` — audit outputs and snapshots (latest: `theme-typography-canon-2026-02-28.md`).
- `ontology/` — ontology model and export references.
