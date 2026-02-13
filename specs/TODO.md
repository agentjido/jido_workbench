# Marketing Pre-Writing Prep — TODO

> **Last updated:** 2026-02-13

---

## Tasks

- [x] **P0 · L** — **Enhance ecosystem source files with maturity/reality data** ✅
      All 19 `priv/ecosystem/*.md` files enhanced with `maturity`, `hex_status`, `api_stability`, `limitations`, `stub`, `support` fields. Schema updated in `AgentJido.Ecosystem.Package`. 2 stable, 3 beta, 12 experimental, 2 planned. `content-system.md` TODO resolved.

- [x] **P0 · M** — **Create canonical glossary** ✅
      Content plan brief created at `priv/content_plan/docs/glossary.md` with 17 terms defined (Agent, Action, Signal, Directive, Strategy, AgentServer, Plugin, Sensor, Instruction, Plan, Schema, Supervision, Orchestration, Runtime, Workflow, Discovery, Scheduler), 3 non-terms flagged, quick reference table, and capitalization conventions.

- [x] **P0 · M** — **Create architecture one-pager** ✅
      Content plan brief created at `priv/content_plan/docs/architecture-overview.md` covering: Think/Act separation, package boundaries, 7 core components, OTP supervision tree, LLM integration layer, state taxonomy (7 locations), responsibility matrix, and 2 Mermaid diagrams.

- [x] **P1 · M** — **Fill proof inventory** ✅
      `marketing/proof.md` is fully populated with 4 pillar sections, proof tables, package coverage, 6 persona requirement sections, and a prioritized TODO list.

- [x] **P1 · M** — **Write canonical page templates** ✅
      `marketing/templates/` contains 6 complete templates (`feature-page.md`, `build-guide.md`, `docs-concept.md`, `docs-reference.md`, `ecosystem-package.md`, `training-module.md`) with structural guidance, tone references, and publishing checklists.

- [ ] **P2 · L** — **Write `/features/reliability-by-architecture`**
      First canonical template page demonstrating the full proof chain and voice in practice. Serves as the reference implementation for all future feature pages.
      🟡 Partial: `priv/pages/features/reliability-by-architecture.md` exists as a stub (`draft: true`, "Content coming soon"). Template and content plan brief exist. Needs actual content written.

---

## Code / Pipeline Tasks (outside `/marketing`)

> These are implementation tasks required to support the finalized content outline. Discovered during outline → content-system gap analysis.

- [x] **P0 · M** — **Add `destination` field to `AgentJido.ContentPlan.Entry` schema** ✅
      Added `destination_route` (optional string) and `destination_collection` (optional atom) to the Zoi schema in `lib/agent_jido/content_plan/entry.ex`. Both fields are optional so existing briefs compile without changes. Content plan entries can now declare their publish target.

- [x] **P0 · M** — **Reconcile content plan sections to match outline IA** ✅
      Moved 28 files, deleted 3 sections (`why/`, `operate/`, `reference/`). Content plan now has 6 sections matching the outline: `build`, `community`, `docs`, `ecosystem`, `features`, `training`. Renamed 7 slug-mismatched files. Updated all cross-references (92+ replacements). Added `destination_route` and `destination_collection` to all 66 entry files. Tests pass.

- [x] **P1 · L** — **Create Features sub-page rendering pipeline** ✅
      Implemented via unified `Pages` system (`lib/agent_jido/pages.ex`). `priv/pages/features/` has 7 pages, compile-time routes generated via `@page_routes`, rendered by `PageLive`. Content is draft/stub — pipeline is complete.

- [x] **P1 · L** — **Create Build section rendering pipeline** ✅
      Implemented via unified `Pages` system. `priv/pages/build/` has 5 pages, routed at `/build` + `/build/:slug`, rendered by `PageLive`. Content is draft/stub — pipeline is complete.

- [x] **P1 · L** — **Create Community section rendering pipeline** ✅
      Implemented via unified `Pages` system. `priv/pages/community/` has 4 pages, routed at `/community` + `/community/:slug`, rendered by `PageLive`. Content is draft/stub — pipeline is complete.

- [ ] **P1 · S** — **Add `/ecosystem/package-matrix` route**
      The outline requires a package-matrix page under ecosystem. Currently `/ecosystem/:id` only resolves package detail pages.
  - Add a dedicated route or static content page for the matrix view
  - Avoid slug collision with package ids

- [ ] **P1 · M** — **Add missing docs content files to `priv/pages/docs/`**
      Docs pipeline migrated from `priv/documentation/docs/` to `priv/pages/docs/` (unified Pages system). Currently has 6 files (`index.md`, `getting-started.livemd`, `cookbook-index.md`, `weather-tool-response.livemd`, `tool-response.livemd`, `chat-response.livemd`). Still needs 7 more:
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

- [x] **P2 · S** — **Update `marketing/content-system.md` route table** ✅
      `marketing/content-system.md` (273 lines, updated 2026-02-12) is comprehensive and current with all 6 content directories, route mapping table, gap analysis, and schema documentation.

---

### Priority Key

| Tag    | Meaning                                       |
| ------ | --------------------------------------------- |
| **P0** | Must complete before any page drafting begins |
| **P1** | Required before content is publishable        |
| **P2** | First real output; validates the whole system |

### Effort Key

| Tag   | Estimate             |
| ----- | -------------------- |
| **S** | A few hours          |
| **M** | Half-day to full day |
| **L** | Multi-day            |
