# Jido Communication & Content Execution Plan

Last updated: 2026-02-21

## Situation

The code is solid. `jido`, `jido_action`, `jido_signal`, `jido_browser`, and `jido_ai` are approaching 2.0 stable. HexDocs are high quality, tests pass, the architecture is real. The codebase homepage and feature pages have strong positioning copy aligned to the brand context.

The gap is execution: turning good positioning into content that reaches two audiences — Elixir devs getting into agents, and non-Elixir devs exploring BEAM for agent workloads.

## What's working (don't touch)

- **Homepage** — Hero, pillars, ecosystem map, install tabs, quick start code, Why Elixir/OTP section. This is strong. Ship it.
- **Feature pages** — All 7 feature sub-pages (`reliability-by-architecture`, `beam-for-ai-builders`, etc.) have real content with proof snippets, capability maps, tradeoffs, and cross-links. These are not stubs.
- **Positioning narrative** — The anchor phrase, ladder, pillars, and differentiation framing are consistent and differentiated. No changes needed.
- **Voice** — "Staff engineer explaining to a peer" is the right register and it's already showing up in the feature page copy.

## What's blocking conversion

1. **Dead-end CTAs.** "GET BUILDING" lands on `/docs/getting-started` which is a 22-line IA stub. Nav "GET STARTED" lands on `/getting-started` (standalone LiveView with real content). Two different destinations, one is empty.
2. **Stub pages in navigation.** `/docs/core-concepts`, `/docs/reference/architecture`, `/docs/reference/production-readiness-checklist`, and all `/docs/reference/*` pages are IA stubs ("reserves route and navigation structure for expanded content"). Visitors who follow cross-links from feature pages hit dead ends.
3. **No terminology anchor.** The "Agent" collision (OTP Agent vs AI Agent) is never addressed. Non-Elixir devs and even Elixir devs new to AI agents will be confused.
4. **Training modules are lesson plans, not lessons.** All 6 training pages are ~62 lines — they describe what you'd learn and give an exercise prompt, but don't teach the concepts or provide runnable code inline.
5. **No failure drill.** The reliability pillar is the strongest differentiator, but there's no runnable demo showing crash → supervisor restart → state recovery. The `reliability-by-architecture` page has a static supervision snippet but no failure behavior.
6. **No multi-agent coordination example.** The `multi-agent-coordination` feature page describes signals/actions/directives but the only runnable examples are single-agent (counter, demand tracker).

## Two audiences, two entry points

Narrow to two tracks for all Phase 1-2 work:

| Track | Who | Entry question | First route |
|---|---|---|---|
| **Elixir builder** | Elixir dev building AI agent features | "How does this map to OTP patterns I know?" | `/features` → `/getting-started` → `/training/agent-fundamentals` |
| **BEAM-curious evaluator** | Python/TS dev who heard BEAM is good for agents | "Why should I learn a new language for this?" | `/features/beam-for-ai-builders` → `/getting-started` → `/examples` |

Everyone else (SRE, CTO, compliance) can be served later once proof assets exist.

## The terminology fix

Add this block **high on every entry-point page** (`/docs/core-concepts`, `/getting-started`, `/features`) and enforce it in all writing:

> **A note on "Agent"**
> In Elixir/OTP, `Agent` is a simple state-holding process from the standard library. In Jido, an Agent is a supervised process that receives Signals, executes typed Actions, and coordinates with other agents — closer to a `GenServer` under OTP supervision than an OTP `Agent`.

Writing rules:
- Use **"OTP Agent"** when referring to the Elixir stdlib module.
- Use **"Jido Agent"** or just **"Agent"** (capitalized) when referring to the Jido concept.
- When addressing non-Elixir devs, say **"isolated processes (lightweight actors)"** before saying "BEAM process."

---

## Phase 0: Fix routing and dead ends

**Effort:** S (a few hours)
**Goal:** Every CTA and cross-link lands on a real page with real content.

### Tasks

- [ ] **0.1 — Consolidate the getting-started split.** The standalone `/getting-started` LiveView has working 2.0 code (deps, agent definition, iex session). The `/docs/getting-started` route is a Pages system stub. Pick one canonical destination for "GET BUILDING." Recommendation: keep the standalone LiveView at `/getting-started` as the CTA target. Update the hero CTA in `jido_home_live.ex` to point to `/getting-started` instead of `/docs/getting-started`. If you want it under `/docs`, move the standalone content there.

- [ ] **0.2 — Audit cross-links from feature pages.** Every feature page has a "What to explore next" section linking to docs stubs. For each link:
  - If the target is a stub → either remove the link, or replace with a link to an existing page that covers the topic (e.g., link to HexDocs instead of `/docs/reference/architecture`).
  - If the target has real content → keep it.

  Pages to audit: all 7 feature pages, `/build/index.md`, and the homepage.

- [ ] **0.3 — Remove or gate stub pages from appearing in navigation.** If the Pages system auto-generates nav entries, ensure pages with stub content either set `draft: true` or `in_menu: false` so visitors don't navigate to dead ends.

---

## Phase 1: The content that converts

**Effort:** M-L (3-5 days)
**Goal:** A developer lands on the site and can answer in 10 minutes: What is this? Is it real? How do I try it?

### 1.1 — Core Concepts page (`/docs/getting-started/core-concepts`)

**Priority:** Highest. This is linked from feature pages and is currently a stub. It's the single most important missing page.

**What to write:**
- 5 concept definitions only: Agent, Action, Signal, Directive, Supervision
- Start with the terminology fix block (Agent vs OTP Agent)
- For each concept: 1-sentence definition → why it exists → ≤10-line code example → link to HexDocs API

**How to write it:**
```
## [Concept Name]

[One sentence: what it is.]

[One sentence: what problem it solves.]

    [Code example, ≤10 lines, from real packages]

Expected result:

    [Output]

For API details, see [HexDocs link].
```

**Don't include:** Deep architecture theory, comparisons, history, or concepts that aren't stable in 2.0 APIs.

### 1.2 — Getting Started consolidation

**Priority:** High. The CTA target must work.

**What to write (enhance the existing `/getting-started` LiveView):**
- Add an "after-state" block at the top: "After 5 minutes you'll have: a supervised agent process, one tool action, one signal emitted, observable logs."
- Add expected output after Step 4 (the iex session) — show what the response actually looks like.
- Add 3 "Next steps" links at the bottom: one example, one training module, one docs page.

### 1.3 — Package matrix page (`/ecosystem/package-matrix`)

**Priority:** High. Route exists (`JidoEcosystemPackageMatrixLive`) but check if it has content.

**What to write:**
- Table with columns: Package, Layer, Purpose, Maturity, When to use
- "Start here" callout: "Most teams start with `jido` + `jido_ai`. Add packages as your needs grow."
- Group by layer (core → intelligence → tools → integrations)

### 1.4 — Architecture overview (`/docs/reference/architecture`)

**Priority:** Medium. Linked from multiple feature pages, currently a stub.

**What to write:**
- One Mermaid diagram: supervision tree + signal flow + action execution + optional LLM layer
- 6-10 bullet narration of the diagram
- "Common extension points" section (only if stable)

**How to write it:** Start from the diagram. Draw what actually runs as processes, how signals flow, where actions execute. Then narrate.

---

## Phase 2: Make "reliable" believable

**Effort:** L (4-7 days)
**Goal:** The reliability claim has runnable proof that skeptics can execute.

### 2.1 — Failure drill example

**Priority:** Highest proof asset. Single most impactful thing you can build.

**What to create:** A new example (like counter-agent) that demonstrates:
1. Start a supervised agent
2. Send it work (actions/signals)
3. Kill the process (`Process.exit(pid, :kill)`)
4. Observe supervisor restart
5. Show what state survives and what resets
6. Show that other agents in the tree are unaffected

**Where it lives:** `lib/agent_jido/demos/` + `priv/examples/failure-drill.md` + LiveView example page

**Writing template:**
```
## What this proves

One agent crashing doesn't take down the system. The supervisor restarts
it with clean state in milliseconds.

## Run it

[Step-by-step with expected output at each step]

## What happened

[Narrate the supervision behavior in 3-4 bullets]

## What Jido guarantees (and doesn't)

[Honest list: restarts yes, state persistence no unless you add it, etc.]
```

### 2.2 — Multi-agent coordination example

**Priority:** High. Proves "engineered coordination, not role-play."

**What to create:** Two agents communicating via signals:
- Agent A receives an event, processes it, emits a signal
- Agent B receives that signal, takes a different action
- Show the signal flow in logs/output

This doesn't need to be complex. A simple "order placed → inventory updated" or "sensor reading → alert triggered" is enough.

### 2.3 — Flesh out one training module

**Priority:** Medium. Pick `agent-fundamentals` since it's the entry point.

**What to write:** Convert the lesson plan into an actual lesson:
- Add the conceptual explanations (currently just bullet headers)
- Add runnable code for each section (currently only an exercise prompt)
- Add expected output after each code block
- Keep it under 200 lines total

---

## Phase 3: Depth and ecosystem confidence

**Effort:** L (1-2 weeks, incremental)
**Goal:** Teams can evaluate, adopt, and operate with confidence.

### 3.1 — Production readiness checklist

Write a real checklist (15-20 items). Be honest: label what's supported today vs recommended practice. Structure:

- [ ] Supervision topology defined
- [ ] Failure modes documented per agent
- [ ] Telemetry events instrumented
- [ ] ...etc

### 3.2 — Additional training module content

Convert remaining 5 training lesson plans into actual lessons with inline code. Prioritize by traffic: `actions-validation` and `signals-routing` before `directives-scheduling` and `liveview-integration`.

### 3.3 — Build section content

Flesh out `/build/quickstarts-by-persona` and `/build/reference-architectures` with real implementation paths. These are currently ~80-110 line pages with structure but light on runnable code.

### 3.4 — Observability basics

Write one page showing:
- What telemetry events Jido emits
- How to see agent state in LiveDashboard (if `jido_live_dashboard` is real enough)
- "If you see X, it means Y" debugging map

---

## Phase 4: Expansion (defer until proof exists)

These are real pages in the content plan but should wait:

| Page | Wait for |
|---|---|
| Executive brief | Real external adoption or case study |
| Incident playbooks | Documented failure modes from production use |
| Security & governance | Implemented policy controls you can demonstrate |
| Case studies | External teams building on Jido |
| Community adoption playbooks | Repeatable adoption patterns from multiple teams |
| Competitor comparison deep-dives | Enough operational proof to make claims credible |

---

## Writing method (for every page)

You write excellent code — use the same discipline for content:

### The loop

1. **Make the example run locally** from a clean project or iex session.
2. **Capture** the commands, the smallest code snippet that matters, and the output.
3. **Write the skeleton** (copy this for every page):

```markdown
## [What this page is about — 1 sentence]

## [When to use this — 3 bullets]

## [Code + expected output]

## [What you get and what you don't — honest]

## What to explore next

- [One example link]
- [One training link]
- [One docs/reference link]
```

4. **Read it aloud.** If you stumble, simplify.
5. **Cut 30%.** Then ask: is anything essential missing?

### Voice check

Before publishing, ask: "Does this read like I'm explaining it in a PR review to a smart colleague?" If yes, it's right. If it reads like a conference talk or a product brochure, rewrite.

### Simplified proof rule (replaces the full proof chain for now)

Every published page must have:
1. One runnable code example with expected output
2. One "what to explore next" section with real links (not stub pages)

Add the full proof chain (package + example + training module) back once Phase 2 is complete.

---

## Execution order (copy-paste checklist)

### This week
- [ ] Phase 0.1 — Fix GET BUILDING CTA destination
- [ ] Phase 0.2 — Audit and fix cross-links from feature pages
- [ ] Phase 0.3 — Hide stubs from navigation
- [ ] Phase 1.1 — Write Core Concepts page
- [ ] Phase 1.2 — Enhance Getting Started with after-state + output + next steps

### Next week
- [ ] Phase 1.3 — Package matrix page
- [ ] Phase 1.4 — Architecture overview with diagram
- [ ] Phase 2.1 — Build failure drill example

### Week after
- [ ] Phase 2.2 — Build multi-agent coordination example
- [ ] Phase 2.3 — Flesh out agent-fundamentals training module
- [ ] Phase 3.1 — Production readiness checklist

### Ongoing after that
- [ ] Phase 3.2-3.4 — Remaining training, build content, observability
- [ ] Phase 4 — Only when external adoption creates proof

---

## What to cut from specs (for speed)

The specs are thorough but over-planned relative to execution. For this phase:

- **Narrow personas** from 9 to 2 tracks (Elixir builder + BEAM-curious evaluator). Serve the rest later.
- **Simplify proof chain** to "one runnable example + one next-step link per page." Restore full chain after Phase 2.
- **Defer** executive brief, competitor deep-dives, incident playbooks, security/governance center, case studies, adoption playbooks.
- **Don't add pages** that require proof you don't have (operational demos, telemetry catalogs, SRE checklists). Write those when the tooling supports them.

## Risk: the one thing that kills trust

Publishing stub pages with "This is a docs IA stub page" text while claiming "production-grade reliability" creates cognitive dissonance. Fix Phase 0 first. A smaller site with real content converts better than a large site with dead ends.
