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

1. ~~**Guide stubs are missing `draft: true`**~~ — ✅ Fixed. All guide stubs have `draft: true`. Cookbook removed.
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
- [x] `docs/getting-started/installation.md` → **done** (manifesto polish, correct req_llm config, inline smoke test)
- [x] `docs/getting-started/first-agent.livemd` → **done** (working Livebook with Mix.install, HTML comment frontmatter)
- [x] `docs/getting-started/first-llm-agent.livemd` → **done** (working Livebook, correct jido_ai ~> 0.2, ReqLLM.put_key)

### Tier 3: Learn — Progressive Tutorials

> **Restructured.** Old training modules (agent-fundamentals, actions-validation, directives-scheduling, signals-routing, tool-use) were deleted — their content lives in Concepts. why-not-just-a-genserver moved to Reference. Learn is now 10 progressive build tutorials. See `specs/learn-content-briefs.md` for full briefs.

#### Jido core mastery

- [x] `docs/learn/first-workflow.livemd` → **done** (working Livebook, action chaining with context.state)
- [ ] `docs/learn/plugins-and-composable-agents.livemd` → **write** — build a NotesPlugin, compose with agents
- [ ] `docs/learn/state-machines-with-fsm.livemd` → **write** — FSM strategy, custom transitions, snapshots
- [ ] `docs/learn/parent-child-agent-hierarchies.livemd` → **write** — 3-layer hierarchy, signal flow, result aggregation
- [ ] `docs/learn/sensors-and-real-time-events.livemd` → **write** — sensors, webhook injection, context-aware routing

#### Jido AI mastery

- [ ] `docs/learn/ai-agent-with-tools.livemd` → **write** — ReAct agent with tools, lifecycle hooks, testing
- [ ] `docs/learn/reasoning-strategies-compared.livemd` → **write** — CoT, ToT, Adaptive side-by-side
- [ ] `docs/learn/task-planning-and-execution.livemd` → **write** — goal decomposition, Memory spaces, task tools
- [ ] `docs/learn/memory-and-retrieval-augmented-agents.livemd` → **write** — Memory, Thread, Retrieval, checkpoint/restore
- [ ] `docs/learn/multi-agent-orchestration.livemd` → **write** — Skills system, Planning plugin, specialist coordination
- [x] `docs/learn/ai-chat-agent.livemd` → **done** (261 lines — will be repositioned into new curriculum)

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

### Tier 5: Guides — Task-Oriented Recipes

MVP guides (5 pages). Each is a standalone Livebook — reader arrives with "I need to do X" and leaves with a working solution. No progressive story required.

- [x] `docs/guides/testing-agents-and-actions.livemd` → **drafted** (400 lines, `draft: true`) — Task: "I need to test my agent." Actions in isolation, `cmd/2` state transitions, runtime testing, debug events, directive assertions.
- [x] `docs/guides/debugging-and-troubleshooting.livemd` → **drafted** (243 lines, `draft: true`) — Task: "Something's wrong." Debug levels, per-agent toggle, ring buffer, timeout diagnostics, state inspection.
- [x] `docs/guides/error-handling-and-recovery.livemd` → **drafted** (198 lines, `draft: true`) — Task: "I need resilience." 5 error policies with working examples, error directives, supervision.
- [x] `docs/guides/persistence-and-checkpoints.livemd` → **drafted** (245 lines, `draft: true`) — Task: "I need to save agent state." ETS vs File adapters, `hibernate/thaw`, thread journals, adapter comparison.
- [x] `docs/guides/building-a-weather-agent.livemd` → **drafted** (256 lines, `draft: true`) — Task: "I need a tool-calling agent." End-to-end ReAct agent with NWS weather tools, custom tools, convenience wrappers.

Deferred guides (post-MVP, no stubs):

- Long-running workflows — deferred until durability/restart patterns are more mature
- MCP integration — deferred until `jido_mcp` is stable
- Mixed-stack runbooks — deferred, niche operational concern
- Persistence + vector search — vector search deferred until supported in deps

### Tier 6: Operations (entire section `draft: true`)

- [ ] `docs/operations/production-readiness-checklist.md` → **stub** (13 lines, `draft: true` ✅)
- [ ] `docs/operations/incident-playbooks.md` → **stub** (13 lines, `draft: true` ✅)
- [ ] `docs/operations/security-and-governance.md` → **stub** (13 lines, `draft: true` ✅)

### Tier 7: Reference

Live reference pages (shipped):

- [x] `docs/reference.md` → **done** (landing page with HexDocs table for all packages)
- [x] `docs/reference/configuration.md` → **done** (158 lines — all config keys for jido + jido_ai)
- [x] `docs/reference/telemetry-and-observability.md` → **done** (210 lines — all events, metrics, jido_otel mention)
- [x] `docs/reference/req-llm-and-llmdb.md` → **done** (78 lines — LLM infrastructure packages)
- [x] `docs/reference/glossary.md` → **done** (79 lines — 20+ terms, canonical definitions)

Drafted reference pages (hidden, for later):

- [x] `docs/reference/debugging.md` → **done** (29 lines, live) — needs research into `Jido.Debug`, debug event modes, IEx helpers
- [x] `docs/reference/why-not-just-a-genserver.livemd` → **done** (moved from learn/, GenServer comparison)
- [ ] `docs/reference/architecture.md` → **stub** (13 lines, `draft: true`) — covered by Concepts for now
- [ ] `docs/reference/architecture-decision-guides.md` → **stub** (13 lines, `draft: true`)
- [ ] `docs/reference/data-storage-and-pgvector.md` → **stub** (13 lines, `draft: true`)
- [ ] `docs/reference/content-governance-and-drift-detection.md` → **stub** (13 lines, `draft: true`) — internal, may never be user-facing
- [ ] `docs/reference/migrations-and-upgrade-paths.md` → **stub** (13 lines, `draft: true`) — nothing to migrate pre-1.0

---

## Summary

| Phase        | Tiers | Pages  | Status                             |
| ------------ | ----- | ------ | ---------------------------------- |
| **MVP**      | 1–4   | 22     | `draft: false` — ships published   |
| **Post-MVP** | 5–7   | 22     | `draft: true` — hidden until ready |
| **Total**    |       | **44** |                                    |

### Current progress

| Section | Done | Remaining | Notes |
| --- | --- | --- | --- |
| Hub pages (T1) | 6/7 | 0 live | operations drafted, rest done |
| Getting started (T2) | 5/5 | 0 | ✅ all done |
| Learn tutorials (T3) | 2/11 | 9 writes | first-workflow + ai-chat-agent done; 9 new tutorials need writing. See `specs/learn-content-briefs.md` |
| Concepts (T4) | 8/8 | 0 | ✅ all done |
| Guides (T5) | 5/5 | 0 | ✅ all drafted (`draft: true`), cookbook removed |
| Operations (T6) | 0/3 | 3 stubs | correctly drafted |
| Reference (T7) | 7/12 | 5 stubs | 7 done + shipped (incl. debugging, why-not-genserver), 5 drafted |

### Recommended writing order (remaining work)

1. **Learn tutorials** (9 pages) — Write in order: plugins → FSM → hierarchies → sensors → AI tools → strategies → task planning → memory/RAG → orchestration. See `specs/learn-content-briefs.md` for full briefs.
2. **Guides** (5 pages) — Testing → Debugging → Error handling → Persistence → Weather agent
3. Remaining reference + operations pages as needed
