# Content System Reference

Last updated: 2026-02-28
Purpose: authoritative map from source files to published routes, with contributor workflow rules.

## 1) System architecture

The site has one unified page pipeline plus supporting content collections.

### Published collections

| Collection | Source path | Loader/build module | Primary routes |
|---|---|---|---|
| Pages | `priv/pages/**/*.{md,livemd}` | `AgentJido.Pages` | `/docs...`, `/features...`, `/build...`, `/community...`, `/training...` |
| Ecosystem | `priv/ecosystem/*.md` | `AgentJido.Ecosystem` | `/ecosystem/:id` + `/ecosystem/package-matrix` |
| Examples | `priv/examples/*.md` | `AgentJido.Examples` | `/examples/:slug` |
| Blog | `priv/blog/**/*.{md,livemd}` | `AgentJido.Blog` | `/blog/:slug`, `/feed`, `/sitemap.xml` |

### Internal collection

| Collection | Source path | Loader/build module | Rendered |
|---|---|---|---|
| Content plan | `priv/content_plan/**/*.md` | `AgentJido.ContentPlan` | No (planning only) |

## 2) Unified pages pipeline (`priv/pages`)

`AgentJido.Pages` is the canonical page pipeline.

- Category is derived from first folder under `priv/pages/`.
- Routes are generated at compile time and wired in `lib/agent_jido_web/router.ex`.
- Both `.md` and `.livemd` are supported through `AgentJido.Pages.LivebookParser`.
- Draft pages are excluded from published indexes.

Compile-time guards already enforce:

- duplicate canonical path detection
- duplicate legacy path detection
- legacy-path collisions with canonical paths
- docs section root shape consistency (`/docs/<section>` must exist when child pages exist)

## 3) Route mapping

| Category | Source pattern | Canonical route pattern |
|---|---|---|
| Docs index | `priv/pages/docs/index.*` | `/docs` |
| Docs pages | `priv/pages/docs/**/*` | `/docs/...` |
| Features pages | `priv/pages/features/*.md` | `/features/:slug` |
| Build pages | `priv/pages/build/*.md` | `/build/:slug` |
| Community pages | `priv/pages/community/*.md` | `/community/:slug` |
| Training pages | `priv/pages/training/*.md` | `/training/:slug` |

Notes:

- `/ecosystem/package-matrix` is an explicit static route and must stay above `/ecosystem/:id` in the router.
- Legacy docs aliases are handled via `AgentJido.Pages.docs_legacy_redirects/0` + `PageController.docs_legacy_redirect/2`.

## 4) Specs to content contract

Think of the flow as:

`specs/*.md` (strategy/rules) -> `priv/content_plan/**/*.md` (briefs) -> `priv/pages|ecosystem|examples|blog` (published content)

Responsibilities:

- `specs/` defines policy, narrative constraints, and quality gates.
- `priv/content_plan/` defines page-level intent and validation metadata.
- `priv/...` published collections contain ship-ready content.

## 5) Contributor workflow

When adding or changing a page:

1. Confirm destination and route in `specs/content-outline.md`.
2. Check tone and terminology in `specs/style-voice.md`.
3. Use the matching template from `specs/templates/`.
4. Ensure claim evidence exists (or update `specs/proof.md`).
5. If needed, update or create the brief in `priv/content_plan/`.
6. Add/update the page in the correct `priv/` collection.
7. Verify cross-links and route parity.

## 6) Required checks before merging

```bash
mix format --check-formatted
mix credo
mix test
mix phx.routes
```

For release or broad route changes, also run:

```bash
mix site.link_audit --include-heex
```

## 7) Anti-drift rules

- Do not add new references to retired path families (`priv/documentation/*`, `priv/content_plan/why/*`, `priv/content_plan/operate/*`).
- Keep route references canonical (`/docs/...`, `/features/...`, `/build/...`, `/community/...`, `/training/...`).
- If route structure changes, update these in the same PR:
  - `specs/README.md`
  - `specs/content-outline.md`
  - `specs/content-system.md`
  - `specs/taxonomy.md`
