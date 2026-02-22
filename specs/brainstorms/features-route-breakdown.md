# Features Route Breakdown

Date: 2026-02-22
Status: Revised after site audit

---

## Scope

This covers the `/features` route tree only. Features is a top-level primary nav item (**Home · Features · Ecosystem · Examples · Docs**) with its own LiveView (`JidoFeaturesLive`) at the index and content pages rendered via the Pages system.

Features pages are positioning and marketing pages — they make the thesis (runtime-first, BEAM-native, model-agnostic) legible to evaluators. They are not documentation.

**Litmus test:** every features page should answer *"Should I adopt this? For what workloads? What proof can I run this week?"* If a page's primary content is *"here's how you use it"*, it belongs in `/docs` or `/build`.

---

## How routing works

Features pages use the `:features` category in the Pages system. Routes are flat: `/features/<id>`. The index `/features` is handled by `JidoFeaturesLive`, not the Pages system. Individual feature pages route through `PageLive` via compile-time generated routes.

Content files live in `priv/pages/features/`.

---

## Route Tree (target: 8 pages + index)

| Route | Title | Status | Priority | Brief file | Notes |
|---|---|---|---|---|---|
| `/features` | Why Jido | outline | P0 | `features/overview.md` | Index page; handled by `JidoFeaturesLive` |
| `/features/reliability-by-architecture` | Supervision and Fault Isolation | published | — | `features/reliability-by-architecture.md` | Done; pillar 1 |
| `/features/multi-agent-coordination` | Signal Routing and Coordination | published | — | `features/multi-agent-coordination.md` | Done; pillar 2 |
| `/features/operations-observability` | Production Telemetry | published | — | `features/operations-observability.md` | Done; pillar 3 |
| `/features/incremental-adoption` | Incremental Adoption Paths | published | — | `features/incremental-adoption.md` | Done; pillar 4 |
| `/features/beam-for-ai-builders` | Why BEAM for AI Builders | published | — | `features/beam-for-ai-builders.md` | Done; non-Elixir evaluator on-ramp |
| `/features/jido-vs-framework-first-stacks` | Jido vs Framework-First Stacks | published | — | `features/jido-vs-framework-first-stacks.md` | Done; competitive positioning |
| `/features/executive-brief` | Executive Brief | published | — | `features/executive-brief.md` | Done; decision-maker summary |
| `/features/beam-native-agent-model` | BEAM-Native Agent Model | needs-page | P0 | `features/beam-native-agent-model.md` | Brief exists; needs `priv/pages` file |

**9 pages** (8 deep-dives + index). 7 published, 1 needs page file.

---

## Summary

| Status | Count |
|---|---|
| Published (has `priv/pages` file) | 7 |
| Needs page (brief exists, no rendered page) | 1 |
| Outline (index only) | 1 |
| **Total** | **9** |

---

## Folded / relocated topics

These content plan briefs exist in `priv/content_plan/features/` but do **not** get their own feature page. Their concepts should be absorbed into the pages listed below.

| Brief | Disposition | Fold into |
|---|---|---|
| `schema-validated-actions` | Fold | *Reliability by Architecture* (typed contracts), *Multi-Agent Coordination* (action boundaries) |
| `directives-and-scheduling` | Fold | *Multi-Agent Coordination* (primary — side-effect control), *Operations & Observability* (mention) |
| `composable-ecosystem` | Fold | *Incremental Adoption* (package composition narrative) + cross-link to `/ecosystem/package-matrix` |
| `liveview-integration-patterns` | Relocate | Move to `/build` or `/docs/guides` — implementation pattern, not evaluator decision page |

**Action items:**
1. Ensure the pillar pages have named subsections for folded concepts (e.g., "Schema-validated Actions" heading inside *Reliability by Architecture*) so evaluators still find them.
2. Update the content plan briefs to reflect `status: :folded` or `status: :relocated` so they don't appear as orphaned work.

---

## Landing page fixes needed

The `JidoFeaturesLive` index has structural issues to resolve:

1. **Category card duplication.** 8 category cards link to only 5 unique deep-dive pages (3 cards → `multi-agent-coordination`, 2 cards → `reliability-by-architecture`). Options:
   - Reduce to ~6 cards with 1:1 page mapping
   - Keep 8 cards but anchor-link to specific sections (e.g., `/features/reliability-by-architecture#typed-actions`)
2. **Hero stats.** "7 deep-dive pages" and "8 feature categories" — update to match final page count.
3. **Missing inbound links.** `beam-native-agent-model` has no link from the landing page. Add it once the `priv/pages` file is created.
4. **`beam-for-ai-builders` and `jido-vs-framework-first-stacks`** are linked from the "Design stance" sidebar but not from category cards or pillars. Consider adding them to the audience paths or as a "Positioning" group on the landing page.

---

## Cross-cutting concerns

These threading items apply across features pages:

1. **"LLM optional by design"** — thread into: `/features` (Why Jido), *Incremental Adoption* (was `composable-ecosystem`, now folded)
2. **ReqLLM first-class visibility** — thread into: *Incremental Adoption* + `/ecosystem/package-matrix`
3. **Runtime-first language primary** — every features page

---

## Resolved questions

1. **Is `/features` a marketing landing page or a content page?** Marketing landing page. `JidoFeaturesLive` stays as a custom LiveView — the landing page needs custom layout/components (pillars grid, category cards, audience paths, adoption lanes) that the Pages system doesn't provide.

2. **Where does "Architecture Overview" live?** Under `/docs/reference/architecture`. It's a docs page. Theme 3 in the consolidated breakdown spans both `/features` and `/docs/reference` — this is correct.

3. **Should `liveview-integration-patterns` be a feature page?** No. It's an implementation guide. Relocate to `/build` or `/docs/guides`.

## Open questions

1. **`beam-native-agent-model` positioning.** The brief is marked `status: :published` in `priv/content_plan` but has no `priv/pages` file. It should be framed as "why this abstraction wins in production" (evaluator narrative), not as a reference doc. Needs writing.

2. **Landing page card restructure.** Needs design decision: reduce card count or add anchor links. Current 8→5 mapping is confusing for evaluators.

3. **Ordering.** Features pages are accessed from the index grid, not sidebar nav. If sidebar nav is ever added, audit `order` values in briefs.
