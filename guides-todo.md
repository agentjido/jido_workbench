# Jido Documentation Guides — Master TODO

**IMPORTANT**

Reference `specs/docs-style-guide.md`, `specs/style-voice.md` and `specs/docs-manifesto.md` when writing guides and documentation.

## Status key

- **done** = page has substantive, manifesto-quality content and is published (`draft: false`)
- **write** = no page exists yet
- **rewrite** = page has real content but needs a fresh manifesto-quality pass
- **stub** = 12-line placeholder file exists but has no real content
- **drafted** = page exists with `draft: true` (hidden from site)

## Ship strategy

Pages support `draft: true` in frontmatter. Draft pages are excluded from nav, listings, search, and return 404 on direct access. **All non-MVP pages ship as `draft: true`** so the site is publishable immediately. Flip `draft: false` as each page is completed and reviewed.

### MVP = what ships on day one (published)

Tiers 1–4 — the minimum path a new user needs to evaluate and start using Jido.

### Post-MVP = draft: true until ready

Everything else. Exists in the repo, invisible on the site, shipped incrementally.

---

## ⚠️ Known issues

1. ~~**Guide stubs are missing `draft: true`**~~ — ✅ Fixed. All guide/cookbook stubs now have `draft: true`.
2. **`operations.md` hub is `draft: true`** — intentional, entire operations section not shipping at release.

---

## Package references → Ecosystem + Reference

`/ecosystem/<package>` is the canonical page for each package overview. The reference section links to HexDocs for API docs and has a dedicated [ReqLLM and LLMDB](/docs/reference/req-llm-and-llmdb) page for the LLM infrastructure layer.

---

## MVP — Ships Published

### Tier 1: Top-Level Hub Pages

Navigation/routing pages. Short, intent-driven, no deep prose.

- [x] `docs/index.md` → **done**
- [x] `docs/getting-started.md` → **done**
- [x] `docs/learn.md` → **done**
- [x] `docs/concepts.md` → **done**
- [x] `docs/guides.md` → **done**
- [x] `docs/reference.md` → **done** (updated with full HexDocs table + 3 live pages)
- [x] `docs/operations.md` → **drafted** (entire operations section is `draft: true` — not ready for release)

### Tier 2: Getting Started — Onboarding Ladder (critical)

The first-time user path. Sequential, must be airtight.

> **Note**: These files live in `docs/getting-started/`, not `docs/learn/`. Legacy paths redirect.

- [x] `docs/getting-started/new-to-elixir.md` → **done** (185 lines, essential Elixir context for newcomers)
- [x] `docs/getting-started/elixir-developers.md` → **done** (93 lines, maps Jido to OTP patterns)
- [ ] `docs/getting-started/installation.md` → **rewrite** (100 lines, solid draft → manifesto polish)
- [ ] `docs/getting-started/first-agent.livemd` → **rewrite** (93 lines, solid draft → manifesto polish)
- [x] `docs/getting-started/first-llm-agent.livemd` → **done** (129 lines, live)

### Tier 3: Learn — Training Modules

Deepen understanding after the onboarding ladder.

- [x] `docs/learn/agent-fundamentals.livemd` → **done** (186 lines — typed state, schemas, signal routing)
- [x] `docs/learn/actions-validation.livemd` → **done** (327 lines — schemas, composition, output validation)
- [x] `docs/learn/directives-scheduling.livemd` → **done** (241 lines — drain loop, scheduling, testing)
- [x] `docs/learn/signals-routing.livemd` → **done** (139 lines — CloudEvents, routing tables, wildcards)
- [x] `docs/learn/tool-use.livemd` → **done** (108 lines — actions as tools, tool calling flow)
- [x] `docs/learn/why-not-just-a-genserver.livemd` → **done** (101 lines — GenServer comparison)
- [ ] `docs/learn/workflows.livemd` → **rewrite** (141 lines, moved from getting-started/first-workflow)

### Tier 4: Concepts

Authoritative explanations of each Jido primitive. Not tutorials.

- [x] `docs/concepts/actions.md` → **done**
- [x] `docs/concepts/signals.md` → **done**
- [x] `docs/concepts/agents.md` → **done**
- [x] `docs/concepts/directives.md` → **done**
- [x] `docs/concepts/agent-runtime.md` → **done**
- [x] `docs/concepts/sensors.md` → **done**
- [x] `docs/concepts/strategy.md` → **done**
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

- [x] `docs/learn/ai-chat-agent.livemd` → **done** (261 lines, published — multi-turn chat, streaming, error handling)
- [ ] `docs/learn/counter-agent.md` → **write** (no file) — refs `/examples/counter-agent`
- [ ] `docs/learn/demand-tracker-agent.md` → **write** (no file) — refs `/examples/demand-tracker-agent`
- [ ] `docs/learn/behavior-tree-without-llm.md` → **write** (no file)
- [ ] `docs/learn/multi-agent-workflows.md` → **write** (no file) — refs `/examples/workflow-coordinator`
- [ ] `docs/learn/liveview-integration.md` → **write** (no file) — refs `/examples/counter-agent`
- [ ] `docs/learn/mixed-stack-integration.md` → **write** (no file)

### Tier 6: Guides — Implementation Patterns

> ⚠️ All stubs below are **missing `draft: true`** in frontmatter — they're visible on the live site as empty pages.

- [ ] `docs/guides/testing-agents-and-actions.livemd` → **stub** (12 lines, needs `draft: true`)
- [ ] `docs/guides/long-running-agent-workflows.livemd` → **stub** (12 lines, needs `draft: true`)
- [ ] `docs/guides/retries-backpressure-and-failure-recovery.livemd` → **stub** (12 lines, needs `draft: true`)
- [ ] `docs/guides/persistence-memory-and-vector-search.livemd` → **stub** (12 lines, needs `draft: true`)
- [ ] `docs/guides/troubleshooting-and-debugging-playbook.livemd` → **stub** (12 lines, needs `draft: true`)
- [ ] `docs/guides/mcp-integration.md` → **write** (no file)

### Tier 7: Operations (entire section `draft: true`)

- [ ] `docs/operations/production-readiness-checklist.md` → **stub** (13 lines, `draft: true` ✅)
- [ ] `docs/operations/incident-playbooks.md` → **stub** (13 lines, `draft: true` ✅)
- [ ] `docs/operations/security-and-governance.md` → **stub** (13 lines, `draft: true` ✅)

### Tier 8: Reference

Live reference pages (shipped):

- [x] `docs/reference.md` → **done** (landing page with HexDocs table for all packages)
- [x] `docs/reference/configuration.md` → **done** (158 lines — all config keys for jido + jido_ai)
- [x] `docs/reference/telemetry-and-observability.md` → **done** (210 lines — all events, metrics, jido_otel mention)
- [x] `docs/reference/req-llm-and-llmdb.md` → **done** (78 lines — LLM infrastructure packages)
- [x] `docs/reference/glossary.md` → **done** (79 lines — 20+ terms, canonical definitions)

Drafted reference pages (hidden, for later):

- [x] `docs/reference/debugging.md` → **done** (29 lines, live) — needs research into `Jido.Debug`, debug event modes, IEx helpers
- [ ] `docs/reference/architecture.md` → **stub** (13 lines, `draft: true`) — covered by Concepts for now
- [ ] `docs/reference/architecture-decision-guides.md` → **stub** (13 lines, `draft: true`)
- [ ] `docs/reference/data-storage-and-pgvector.md` → **stub** (13 lines, `draft: true`)
- [ ] `docs/reference/content-governance-and-drift-detection.md` → **stub** (13 lines, `draft: true`) — internal, may never be user-facing
- [ ] `docs/reference/migrations-and-upgrade-paths.md` → **stub** (13 lines, `draft: true`) — nothing to migrate pre-1.0

---

## Summary

| Phase        | Tiers | Pages  | Status                             |
| ------------ | ----- | ------ | ---------------------------------- |
| **MVP**      | 1–4   | 29     | `draft: false` — ships published   |
| **Post-MVP** | 5–8   | 24     | `draft: true` — hidden until ready |
| **Total**    |       | **53** |                                    |

### Current progress

| Section | Done | Remaining | Notes |
| --- | --- | --- | --- |
| Hub pages (T1) | 6/7 | 0 live | operations drafted, rest done |
| Getting started (T2) | 3/5 | 2 rewrites | new-to-elixir, elixir-devs, first-llm-agent done; installation + first-agent need polish |
| Training modules (T3) | 6/7 | 1 rewrite | workflows moved from getting-started |
| Concepts (T4) | 8/8 | 0 | ✅ all done |
| Build guides (T5) | 1/7 | 6 writes | ai-chat-agent done; 6 no file yet |
| Guides (T6) | 0/6 | 5 stubs + 1 no file | ⚠️ stubs need `draft: true` |
| Operations (T7) | 0/3 | 3 stubs | correctly drafted |
| Reference (T8) | 6/11 | 5 stubs | 6 done + shipped (incl. debugging), 5 drafted |

### Recommended writing order (remaining work)

1. **Fix stubs** — add `draft: true` to Tier 6 guide stubs so empty pages aren't live
2. **Tier 2 rewrites** (2 pages) — manifesto polish on installation, first-agent
3. **Tier 3 rewrite** (1 page) — workflows (moved from getting-started)
4. **Tier 5 build guides** (6 pages) — write counter-agent, demand-tracker, etc.
5. **Tier 6 guides** (6 pages) — write when ready, flip `draft: false`
6. Remaining reference + operations pages as needed
