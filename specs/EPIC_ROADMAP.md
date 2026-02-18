# AgentJido Epic Roadmap

Last updated: 2026-02-18

## Purpose

This document turns current project state into an execution plan across:

1. Production authentication + admin control plane
2. Site-wide Arcana search
3. Messaging + ChatOps admin console
4. Content publishing and rollout

## Current State Snapshot

### What is already in place

- Authentication foundation exists (`phx.gen.auth` style):
  - Session + magic-link + password flows
  - Admin role flag (`users.is_admin`)
  - Admin promotion helpers + mix task
  - Public registration route disabled
- Admin guards exist for both Plug and LiveView:
  - `:require_authenticated_user`
  - `:require_admin_user`
  - `on_mount :require_admin`
- Dev control surfaces are already protected:
  - LiveDashboard
  - Jido Studio
  - Arcana dashboard
  - ContentOps dashboards
- Arcana ingestion pipeline is implemented:
  - Idempotent ingest from docs/blog/ecosystem
  - Arcana health task
  - Graph extraction gating by runtime config
- Chat subsystem is substantial:
  - Telegram + Discord handlers
  - Room bindings + bridge forwarding
  - Command router, authorizer, policy gates
  - Integration/unit tests
- Content system is implemented:
  - Unified `priv/pages/*` pipeline and routes
  - Training + docs pages have real content

### Key gaps (blocking your target outcome)

- Admin surfaces are currently behind `:dev_routes` compile-time gating, so they are not production-safe by default.
- There is no protected `/dashboard` app route for post-login admin landing.
- Login redirect does not target a dedicated admin dashboard path.
- Arcana-powered public site search LiveView does not exist yet.
- No authenticated admin ChatOps web console exists yet (to inspect rooms/messages/actions).
- Features/build/community content pages are mostly draft placeholders.

## Test and Audit Evidence

- Registration is disabled by route and test coverage.
- Auth/admin protections are tested in router and auth tests.
- ContentOps LiveView tests currently expect unauthenticated access, but routes now require login/admin and tests fail accordingly.
- Chat integration tests pass when `CONTENTOPS_CHAT_ENABLED=false`, but fail when chat is auto-started from env during tests due already-started processes.

## Epic 1: Production Auth + Admin Control Plane

### Goal

Single-admin workflow in production with protected `/dashboard`, no public registration, and authenticated access to admin tools (Arcana + Jido Studio + ContentOps).

### Current status

In progress (foundation complete, production routing model incomplete).

### Deliverables

1. Create a production-safe admin scope in router:
   - Keep mailbox in `:dev_routes`.
   - Move protected admin app routes out of `:dev_routes`.
2. Add `live "/dashboard", AdminDashboardLive, :index` behind:
   - pipeline: `[:browser, :require_authenticated_user, :require_admin_user]`
   - `live_session :require_authenticated_user` (or existing authenticated session) with `on_mount` checks.
3. Add links from `/dashboard` to:
   - Arcana dashboard
   - Jido Studio
   - ContentOps dashboards
4. Update sign-in redirect behavior:
   - Admin users: `/dashboard`
   - Non-admin users: existing path (or explicit restricted path policy)
5. Add/adjust tests:
   - unauthenticated -> login redirect
   - authenticated non-admin -> blocked
   - authenticated admin -> success
6. Finalize single-admin bootstrapping path:
   - `ADMIN_EMAIL` seed path
   - `mix accounts.promote_admin <email>`
   - production checklist runbook

### Acceptance criteria

- Admin user can log in on production and land on `/dashboard`.
- `/dashboard` is inaccessible to non-admin and unauthenticated users.
- Arcana/Jido/ContentOps tools are reachable only through authenticated admin routing.
- Public registration remains unavailable.

## Epic 2: Site-wide Arcana Search LiveView

### Goal

Add a dedicated search experience for all site content powered by Arcana (graph/vector/hybrid).

### Current status

Not started for UI/routing (backend ingest exists).

### Deliverables

1. Add a new public LiveView route:
   - `/search` (query + results in one view or index/results actions)
2. Add a search context module to centralize Arcana queries:
   - Collections: `site_docs`, `site_blog`, `site_ecosystem`
   - Mode: `:hybrid` with sensible fallbacks
3. Build result model:
   - title
   - snippet
   - canonical route/url
   - source type (docs/blog/ecosystem)
   - relevance score (optional display)
4. Add empty/loading/error states and telemetry.
5. Add tests:
   - no query
   - query with results
   - query with no results
   - backend failure fallback

### Acceptance criteria

- `/search` returns cross-collection results from Arcana.
- Results link to real site destinations.
- Query latency and failure handling are acceptable for production.

## Epic 3: Messaging + Admin ChatOps Console

### Goal

Operate Telegram/Discord chat interactions from an authenticated web admin panel, with visibility into chats and actions.

### Current status

Core messaging runtime exists; admin web console not started.

### Deliverables

1. Create authenticated admin ChatOps LiveView (under `/dashboard/...`):
   - room list
   - recent messages
   - action/run timeline
2. Wire to existing chat stores/services (`JidoMessaging`, run store, notifier, router metadata).
3. Add guardrails:
   - display authz status for command actor rules
   - clear mutation-enabled indicator
4. Production hardening:
   - decide storage durability for prod messaging history
   - make test env deterministic (prevent env leakage into test boot)
5. Add operational runbook:
   - required env vars
   - channel ID mapping
   - startup/health validation steps

### Acceptance criteria

- Admin can observe incoming platform chats in web UI.
- Admin can see actions/runs triggered from chat.
- Unauthorized actors are visibly blocked by policy.

## Epic 4: Content Rollout and Landing Execution

### Goal

Move from placeholders to shippable content in highest-impact sections.

### Current status

In progress (pipeline complete, major sections still draft placeholders).

### Deliverables

1. Publish landing-page-aligned content in order:
   - Features first
   - Build second
   - Community third
2. Convert draft placeholders:
   - `priv/pages/features/*` (7 draft pages)
   - `priv/pages/build/*` (5 draft pages)
   - `priv/pages/community/*` (4 draft pages)
3. Fill docs IA gaps tracked in `specs/TODO.md` (missing docs pages).
4. Add `ecosystem/package-matrix` route/page.
5. Add basic content freshness checklist to release cadence.

### Acceptance criteria

- Core nav sections have non-placeholder content.
- Draft flags are removed only when pages meet quality/proof criteria.
- Content outline and live routes stay in sync.

## Milestone Plan

### Milestone 1 (Auth/Admin Foundation) - 1 week

- Router restructuring for production-safe admin routes
- `/dashboard` live view + login redirect policy
- Auth test updates and pass

### Milestone 2 (Search V1) - 1 to 1.5 weeks

- `/search` LiveView + Arcana query context
- Cross-collection results + tests
- Header/nav entry point to search

### Milestone 3 (ChatOps Console V1) - 1.5 to 2 weeks

- Admin chat monitor UI
- Message/action timeline
- Env/test hardening and operational docs

### Milestone 4 (Content Publish Wave) - ongoing, parallel

- Priority feature pages + landing page cohesion
- Build/community drafts converted
- Missing docs pages and package matrix delivered

## Immediate Next Actions (Suggested)

1. Implement Epic 1 first: make `/dashboard` production-safe and wire auth redirects.
2. Build Search V1 second: it depends on existing Arcana ingest that is already done.
3. Build ChatOps admin console third using existing messaging runtime.
4. Run content publishing in parallel with engineering milestones.
