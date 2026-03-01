# Jido Documentation Guides — Master TODO

**IMPORTANT**

Reference `specs/docs-style-guide.md`, `specs/style-voice.md` and `specs/docs-manifesto.md` when writing guides and documentation.

## Status key

- **write** = no page exists or is a 12-line stub
- **rewrite** = page has real content but needs a fresh manifesto-quality pass

## Ship strategy

Pages support `draft: true` in frontmatter. Draft pages are excluded from nav, listings, search, and return 404 on direct access. **All non-MVP pages ship as `draft: true`** so the site is publishable immediately. Flip `draft: false` as each page is completed and reviewed.

### MVP = what ships on day one (published)

Tiers 1–3 plus Concepts — the minimum path a new user needs to evaluate and start using Jido.

### Post-MVP = draft: true until ready

Everything else. Exists in the repo, invisible on the site, shipped incrementally.

---

## Package references → Ecosystem

`/ecosystem/jido` is the canonical page for each package. The `docs/reference/packages/` section has been removed. All cross-links now point to `/ecosystem/<package>` for package-level details and HexDocs for API docs.

---

## MVP — Ships Published

### Tier 1: Top-Level Hub Pages

Navigation/routing pages. Short, intent-driven, no deep prose.

- [ ] `docs/index.md` → **rewrite** (stub → intent-based routing page)
- [ ] `docs/getting-started.livemd` → **rewrite** (stub → onboarding funnel)
- [ ] `docs/learn.md` → **rewrite** (stub → progression map)
- [ ] `docs/concepts.md` → **rewrite** (stub → primitive map with reading order)
- [ ] `docs/guides.md` → **rewrite** (stub → guide index)
- [ ] `docs/operations.md` → **rewrite** (stub → ops routing)
- [ ] `docs/reference.md` → **rewrite** (stub → reference index, links to /ecosystem for packages)

### Tier 2: Learn — Onboarding Ladder (wave_1, critical)

The first-time user path. Sequential, must be airtight.

- [ ] `docs/learn/installation.livemd` → **rewrite** (solid draft → manifesto polish)
- [ ] `docs/learn/first-agent.livemd` → **rewrite** (solid draft → manifesto polish)
- [ ] `docs/learn/first-llm-agent.livemd` → **rewrite** (solid draft → manifesto polish)
- [ ] `docs/learn/first-workflow.livemd` → **rewrite** (solid draft → manifesto polish)

### Tier 3: Learn — Training Modules

Deepen understanding after the onboarding ladder.

- [ ] `docs/learn/agent-fundamentals.md` → **rewrite** (solid draft → manifesto polish)
- [ ] `docs/learn/actions-validation.md` → **write**
- [ ] `docs/learn/directives-scheduling.md` → **write**
- [ ] `docs/learn/signals-routing.md` → **write**
- [ ] `docs/learn/tool-use.md` → **write**
- [ ] `docs/learn/why-not-just-a-genserver.md` → **write**

### Tier 4: Concepts

Authoritative explanations of each Jido primitive. Not tutorials.

- [x] `docs/concepts/actions.livemd` → **done**
- [x] `docs/concepts/signals.livemd` → **done**
- [x] `docs/concepts/agents.livemd` → **done** (solid draft, manifesto-aligned)
- [x] `docs/concepts/directives.livemd` → **done**
- [x] `docs/concepts/agent-runtime.livemd` → **done**
- [x] `docs/concepts/sensors.md` → **done** (new page)
- [x] `docs/concepts/strategy.md` → **done** (new page)
- [x] `docs/concepts/plugins.md` → **done**

---

## Post-MVP — Ships as `draft: true`

### Tier 5: Learn — Build Guides

Hands-on projects. Each build guide teaches via a focused livemd tutorial under `/docs/learn/` and links to the full working implementation under `/examples/`.

| Build guide                 | Example reference                              |
| --------------------------- | ---------------------------------------------- |
| `counter-agent`             | `/examples/counter-agent` (live)               |
| `demand-tracker-agent`      | `/examples/demand-tracker-agent` (live)        |
| `ai-chat-agent`             | `/examples/coding-assistant` or similar (live) |
| `behavior-tree-without-llm` | — (needs example)                              |
| `multi-agent-workflows`     | `/examples/workflow-coordinator` (live)        |
| `liveview-integration`      | `/examples/counter-agent` (live, has LiveView) |
| `mixed-stack-integration`   | — (needs example)                              |

- [ ] `docs/learn/counter-agent.md` → **write** — refs `/examples/counter-agent`
- [ ] `docs/learn/demand-tracker-agent.md` → **write** — refs `/examples/demand-tracker-agent`
- [ ] `docs/learn/ai-chat-agent.livemd` → **rewrite** — refs relevant example
- [ ] `docs/learn/behavior-tree-without-llm.md` → **write**
- [ ] `docs/learn/multi-agent-workflows.md` → **write** — refs `/examples/workflow-coordinator`
- [ ] `docs/learn/liveview-integration.md` → **write** — refs `/examples/counter-agent`
- [ ] `docs/learn/mixed-stack-integration.md` → **write**

### Tier 6: Guides — Implementation Patterns

- [ ] `docs/guides/cookbook.md` → **write** (stub, hub page)
- [ ] `docs/guides/testing-agents-and-actions.livemd` → **write** (stub)
- [ ] `docs/guides/long-running-agent-workflows.livemd` → **write** (stub)
- [ ] `docs/guides/retries-backpressure-and-failure-recovery.livemd` → **write** (stub)
- [ ] `docs/guides/persistence-memory-and-vector-search.livemd` → **write** (stub)
- [ ] `docs/guides/troubleshooting-and-debugging-playbook.livemd` → **write** (stub)
- [ ] `docs/guides/mcp-integration.md` → **write** (no page exists)
- [ ] `docs/guides/mixed-stack-runbooks.md` → **write** (stub)

### Tier 7: Guides — Cookbook Recipes

- [ ] `docs/guides/cookbook/chat-response.livemd` → **write** (stub)
- [ ] `docs/guides/cookbook/tool-response.livemd` → **write** (stub)
- [ ] `docs/guides/cookbook/weather-tool-response.livemd` → **write** (stub)

### Tier 8: Operations

- [ ] `docs/operations/production-readiness-checklist.md` → **write** (stub)
- [ ] `docs/operations/incident-playbooks.md` → **write** (stub)
- [ ] `docs/operations/security-and-governance.md` → **write** (stub)
- [ ] `docs/operations/backup-and-disaster-recovery.md` → **write** (no page exists)

### Tier 9: Reference

- [ ] `docs/reference/architecture.md` → **write** (stub)
- [ ] `docs/reference/configuration.md` → **write** (stub)
- [ ] `docs/reference/glossary.md` → **write** (stub)
- [ ] `docs/reference/telemetry-and-observability.md` → **write** (stub)
- [ ] `docs/reference/data-storage-and-pgvector.md` → **write** (stub)
- [ ] `docs/reference/architecture-decision-guides.md` → **write** (stub)
- [ ] `docs/reference/ai-integration-decision-guide.md` → **write** (no page exists)
- [ ] `docs/reference/provider-capability-and-fallback-matrix.md` → **write** (no page exists)
- [ ] `docs/reference/content-governance-and-drift-detection.md` → **write** (stub)
- [ ] `docs/reference/migrations-and-upgrade-paths.md` → **write** (stub)

### Tier 10: Community

- [ ] `docs/community/` hub → **write** (no page exists)
- [ ] `docs/community/adoption-playbooks.md` → **write** (no page exists)
- [ ] `docs/community/case-studies.md` → **write** (no page exists)
- [ ] `docs/community/learning-paths.md` → **write** (no page exists)
- [ ] `docs/community/manager-roadmap.md` → **write** (no page exists)

---

## Summary

| Phase        | Tiers | Pages  | Status                             |
| ------------ | ----- | ------ | ---------------------------------- |
| **MVP**      | 1–4   | 29     | `draft: false` — ships published   |
| **Post-MVP** | 5–10  | 35     | `draft: true` — hidden until ready |
| **Total**    |       | **64** |                                    |

### Recommended MVP writing order

1. Tier 1 hub pages (7) — navigation skeleton
2. Tier 2 onboarding ladder (4) — critical first-user path
3. Tier 4 concepts (7) — foundations everything links to
4. Tier 3 training modules (6) — deepen after onboarding
5. Then flip `draft: false` on post-MVP pages as they're completed
