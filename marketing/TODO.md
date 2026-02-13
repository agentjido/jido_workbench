# Marketing Pre-Writing Prep — TODO

> **Last updated:** 2026-02-12

---

## Tasks

- [ ] **P0 · L** — **Enhance ecosystem source files with maturity/reality data**
  The files in `priv/ecosystem/*.md` are the source of truth for package metadata. They need to be enhanced to include:
  - Maturity tier (`stable` / `beta` / `experimental` / `planned`)
  - Hex.pm publication status (published version or `"unreleased"`)
  - API stability expectations
  - Known limitations / non-goals
  - Whether the package is a stub vs real usable code
  - Support expectations (`best-effort` / `community` / `maintained`)

  This replaces the need for a separate "reality ledger" — the ecosystem files **ARE** the ledger, they just need these fields.

- [ ] **P0 · M** — **Create canonical glossary**
  Write a glossary defining Jido's loaded terms — *agent, action, signal, directive, strategy, runtime, workflow, orchestration, supervision, operability, sensor, plugin*, etc. — with:
  - One-paragraph definitions
  - Use/avoid guidance
  - Consistent capitalization rules
  - Cross-links between related terms

  Should eventually live at `/docs/glossary` or `/docs/core-concepts/glossary`.
  **Action:** Add a content plan brief in `priv/content_plan/docs/glossary.md`.

- [ ] **P0 · M** — **Create architecture one-pager**
  A single "Jido at 10,000 feet" diagram + narrative showing:
  - Core components and their boundaries
  - Where OTP fits
  - Where LLM providers / tools plug in
  - Where state lives
  - What's inside vs outside Jido's responsibility

  Should eventually be published at `/docs/architecture` or `/docs/core-concepts/architecture`.
  **Action:** Add a content plan brief in `priv/content_plan/docs/architecture-overview.md`.

- [ ] **P1 · M** — **Fill proof inventory**
  `marketing/proof.md` has been created as a skeleton. Go find and fill in concrete proof points:
  - Runnable examples
  - Training modules
  - Reference docs
  - Operational demos per messaging pillar

- [ ] **P1 · M** — **Write canonical page templates**
  Template skeletons have been created in `marketing/templates/`. Fill them in with real worked examples using Jido content.

- [ ] **P1 · S** — **Resolve open decisions from `critique.md`**
  - Decision #5 — Pillar proof briefs
  - Decision #8 — Reference template page
  - Decision #10 — Journey route reconciliation
  - Decision #11 — Missing content plan briefs

- [ ] **P2 · L** — **Write `/features/reliability-by-architecture`**
  First canonical template page demonstrating the full proof chain and voice in practice. Serves as the reference implementation for all future feature pages.

---

## Code / Pipeline Tasks (outside `/marketing`)

> These are implementation tasks required to support the finalized content outline. Discovered during outline → content-system gap analysis.

- [ ] **P0 · M** — **Add `destination` field to `AgentJido.ContentPlan.Entry` schema**
  The content plan entry schema (`lib/agent_jido/content_plan/entry.ex`) has no field to declare where a brief should publish. Add:
  - `destination_route` — target URL path (e.g., `/features/reliability-by-architecture`)
  - `destination_collection` — target priv/ directory (e.g., `:documentation`, `:training`, `:features`)
  This enables programmatic validation of outline → brief → content coverage.

- [ ] **P0 · M** — **Reconcile content plan sections to match outline IA**
  Three content plan sections (`why/`, `operate/`, `reference/`) don't exist in the locked outline. Either:
  - Move/rename briefs to their outline-correct sections, OR
  - Use the new `destination_route` field to map them while keeping the current folder structure
  Also rename mismatched slugs (e.g., `core-concepts-hub` → `core-concepts`, `supervision-and-fault-isolation` → `reliability-by-architecture`).
  See `marketing/content-system.md` § "Content plan section → outline reconciliation" for the full mapping table.

- [ ] **P1 · L** — **Create Features sub-page rendering pipeline**
  The outline requires `/features/:slug` routes for 7 sub-pages. Currently `/features` is a single hardcoded LiveView.
  - Create `priv/features/` content directory (or reuse `priv/documentation/` with a `:features` category)
  - Create schema module + NimblePublisher loader (or extend existing documentation pipeline)
  - Add routes: either compile-time static routes or `/features/:slug` dynamic route
  - Add LiveView for rendering feature detail pages

- [ ] **P1 · L** — **Create Build section rendering pipeline**
  The outline requires `/build` index + `/build/:slug` detail pages. No pipeline exists.
  - Create `priv/build/` content directory (or extend documentation with `:build` category)
  - Create schema module + NimblePublisher loader
  - Add routes (`/build`, `/build/:slug`)
  - Add LiveView(s)

- [ ] **P1 · L** — **Create Community section rendering pipeline**
  The outline requires `/community` index + `/community/:slug` detail pages. No pipeline exists.
  - Create `priv/community/` content directory (or extend documentation with `:community` category)
  - Create schema module + NimblePublisher loader
  - Add routes (`/community`, `/community/:slug`)
  - Add LiveView(s)

- [ ] **P1 · S** — **Add `/ecosystem/package-matrix` route**
  The outline requires a package-matrix page under ecosystem. Currently `/ecosystem/:id` only resolves package detail pages.
  - Add a dedicated route or static content page for the matrix view
  - Avoid slug collision with package ids

- [ ] **P1 · M** — **Add missing docs content files to `priv/documentation/docs/`**
  The documentation pipeline works but only has 2 files. The outline requires 7 more:
  - `core-concepts.md`
  - `guides.md` (or `guides/index.md`)
  - `reference.md` (or `reference/index.md`)
  - `architecture.md`
  - `production-readiness-checklist.md`
  - `security-and-governance.md`
  - `incident-playbooks.md`
  These can be stubs initially — the pipeline will pick them up automatically.

- [ ] **P2 · S** — **Clean up orphan routes**
  - `/partners` is aliased to `JidoFeaturesLive` — remove or redirect
  - `/getting-started` exists as a standalone LiveView but outline places getting-started under `/docs/getting-started` — reconcile or redirect

- [ ] **P2 · S** — **Update `marketing/content-system.md` route table**
  Once new pipelines are implemented, update the "Content → route mapping" table and directory documentation to reflect the new sections.

---

### Priority Key

| Tag | Meaning |
|-----|---------|
| **P0** | Must complete before any page drafting begins |
| **P1** | Required before content is publishable |
| **P2** | First real output; validates the whole system |

### Effort Key

| Tag | Estimate |
|-----|----------|
| **S** | A few hours |
| **M** | Half-day to full day |
| **L** | Multi-day |
