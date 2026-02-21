# Jido — Complete Brand, Positioning & Content Context

> **Purpose:** Paste this into any LLM conversation to give full context on Jido's positioning, messaging, voice, personas, content rules, and governance constraints. If you can't cite proof for a claim, soften or remove it.

---

## 1) Non-Negotiable Constants

- **Anchor phrase:** `Jido is a runtime for reliable, multi-agent systems.`
- **Differentiator:** `Built on Elixir/OTP for fault-tolerant concurrency and production-grade reliability.`
- **Intelligence posture:** Model-agnostic runtime. LLM integration is optional via add-on packages (`jido_ai`, `req_llm`).
- **Product posture:** Open source. CTAs drive self-serve builder onboarding.
- **Primary CTA:** `Get Building`
- **Hero headline (locked):** `A runtime for reliable, multi-agent systems.`
- **Hero subhead (locked):** `Design, coordinate, and operate agent workflows that stay stable in production — built on Elixir/OTP for fault isolation, concurrency, and uptime.`
- **Target nav (locked):** `Features | Ecosystem | Examples | Training | Docs | Community | Get Building`

### What Jido is not

- Not only a prompt-orchestration helper.
- Not only an LLM API wrapper.
- Not optimized for weekend demo velocity at the cost of runtime safety.

---

## 2) Positioning Narrative

### One-line positioning statement

Jido helps engineering teams move from fragile agent prototypes to production-grade multi-agent systems with explicit coordination, fault isolation, and operational control.

### Category claim

`Reliable Multi-Agent Runtime Platform`

### Market point of view

Most agent tools make it easy to start and hard to operate. Jido is built for operation:

- Sustained uptime
- Predictable behavior under concurrency
- Explicit failure handling
- Real observability and runbooks

**Core message:** `Prototyping is common. Reliable operation is rare. Jido is built for operation.`

### Why now

AI product teams are moving from single LLM calls to multi-step, tool-using, multi-agent workflows. This introduces state/lifecycle complexity, cross-agent coordination risk, operational/compliance pressure, and cost/latency management challenges. Jido's value rises as complexity rises.

### USP

Jido treats multi-agent systems as a **runtime architecture problem**, not just a prompt design problem.

### Why Elixir/OTP matters

| Technical reason | Buyer translation |
|---|---|
| Process isolation reduces blast radius | Fewer cascading failures |
| Supervision gives restart/recovery semantics | Faster debugging of weird runtime behavior |
| Concurrency primitives support many long-lived agents | Safer scaling from one workflow to many |
| OTP operational model for incident handling | Better total cost over lifecycle, not just day-one |

### Multi-agent thesis

Agents communicate through structured signals, capabilities are typed actions, orchestration uses directives and strategies, scheduling and temporal behavior are part of runtime design.

**Message to repeat:** `Multi-agent in Jido is engineered coordination, not role-play in a single prompt.`

### Narrative ladder (use consistently across pages)

1. Broad: `Jido is a runtime for reliable, multi-agent systems.`
2. Outcome: `Design, coordinate, and operate agent workflows that stay stable in production.`
3. Technical differentiator: `Built on Elixir/OTP for fault isolation, concurrency, and uptime.`
4. Category contrast: `Not only framework APIs, but a runtime model for production operation.`

---

## 3) Differentiation Framing

Use a respectful "fit-for-purpose" narrative, never attack copy.

| Dimension | Prototype-first frameworks | Jido |
|---|---|---|
| Primary optimization | Fast initial setup | Reliable long-term operation |
| Runtime model | App-layer orchestration | Runtime-layer supervision and lifecycle |
| Failure handling | Often ad hoc at app level | Explicit OTP supervision and containment |
| Multi-agent coordination | Prompt/procedure heavy | Structured signals/actions/directives |
| Operations posture | Add observability later | Observability and operations first-class |
| Best fit | Rapid experiments | Production multi-agent systems |

**Comparison line:** `If you need to prove an idea quickly, many tools can work. If you need agents to run continuously and safely in production, Jido is the better fit.`

**Competitor mention rules:** Name competitors when the comparison is specific and technical (e.g., "Unlike CrewAI's prompt-chain model, Jido uses typed signals"). Use category labels ("prototype-first frameworks") for general claims. Never disparage.

---

## 4) Messaging Pillars

### Pillar 1: Reliability by architecture

Core message: Agents should fail safely and recover predictably.
Proof surfaces: supervision examples, failure drills, production runbooks.

### Pillar 2: Multi-agent coordination you can reason about

Core message: Complex agent behavior should be explicit and testable.
Proof surfaces: signal routing patterns, directive examples, workflow traces.

### Pillar 3: Production operations and observability

Core message: Real systems need telemetry, debugging workflows, and controls.
Proof surfaces: dashboard instrumentation, trace narratives, SRE checklists.

### Pillar 4: Composable ecosystem with incremental adoption

Core message: Adopt only what you need now, expand safely later.
Proof surfaces: package matrix, minimal-stack quickstarts, migration guides.

### Proof rule

Every pillar must reference at least one package, one runnable example, and one training module.

---

## 5) Objection Handling

**"We are not an Elixir shop."**
→ Use Jido as a bounded agent service. Integrate via APIs/events. Expand only when reliability gains are proven.

**"This looks heavier than other agent frameworks."**
→ Intentionally production-oriented. Heavier upfront structure lowers long-term incident and maintenance cost.

**"Can this handle real multi-agent complexity?"**
→ Coordination is explicit via signals/actions/directives. Behavior can be inspected, tested, and traced.

**"How do we de-risk adoption?"**
→ Start with a single critical workflow. Use training + reference architecture checkpoints. Define go/no-go criteria around reliability and operability.

---

## 6) Claim Discipline

### Claims to make

- Designed for reliable multi-agent runtime behavior on the BEAM.
- Built for production operation, not only prototype speed.
- Structured coordination model for complex agent workflows.

### Claims to avoid

- "Best agent framework."
- "Solves every AI architecture problem."
- Unbounded performance claims without benchmarks and workload context.

---

## 7) Personas & Journeys

### Strategy premise

- Do not assume visitors know Elixir or BEAM.
- Lead with outcomes and operational confidence.
- Introduce Elixir/OTP as the reason reliability claims are credible.
- Give non-Elixir teams safe, bounded adoption paths.
- Frame BEAM advantages as outcome comparisons, not community advocacy.

### Priority personas

| Persona | Core question | Promise | First route |
|---|---|---|---|
| Elixir platform engineer | How does this map to OTP patterns? | Reliable agent architecture aligned to supervision | `/features` |
| AI product engineer | How do I ship AI features safely? | Tool-using agent patterns with fewer runtime surprises | `/build` |
| Staff architect / tech lead | Can this scale across teams? | Reference architecture and governance path | `/ecosystem/package-matrix` |
| Python AI engineer | Why Jido vs Python-first frameworks? | Better runtime semantics for long-lived workloads | `/features/beam-for-ai-builders` |
| TypeScript fullstack engineer | Can this be my backend agent service? | Mixed-stack integration with clear boundaries | `/build/mixed-stack-integration` |
| Platform/SRE engineer | Is this operable and safe under failure? | Runbooks, telemetry, and reliability controls | `/docs/production-readiness-checklist` |
| Security/compliance engineer | How do we control tool risk? | Policy, guardrails, and auditability guidance | `/docs/security-and-governance` |
| Engineering manager | How do I de-risk team adoption? | 30/60/90 staged rollout and training roadmap | `/training/manager-roadmap` |
| CTO/founder | Is this strategic and practical now? | Differentiation + phased execution plan | `/features/executive-brief` |

### Intent stages

| Stage | User intent | Required proof | Best surfaces |
|---|---|---|---|
| Awareness | Understand what Jido is | Problem statement + differentiation | `/features` |
| Orientation | Map to current stack | Persona quickstarts + package matrix | `/build/quickstarts-by-persona`, `/ecosystem/package-matrix` |
| Evaluation | Test feasibility | Runnable examples + constraints | `/examples`, `/training/agent-fundamentals` |
| Activation | Ship first feature | Guides + validation checklists | `/build`, `/docs/guides`, `/training` |
| Operationalization | Run safely in production | Runbooks + telemetry + rollback | `/docs/production-readiness-checklist` |
| Expansion | Scale across teams | Governance patterns + architecture decisions | `/community/adoption-playbooks` |
| Advocacy | Teach and standardize | Reusable assets + case studies | `/community` |

### Canonical journeys

**A) Non-Elixir evaluator** → `/features/beam-for-ai-builders` → `/ecosystem/package-matrix` → `/examples/counter-agent` → `/build/mixed-stack-integration` → `/docs/reference`
Success: first cross-stack workflow with production guardrails.

**B) Elixir-native builder** → `/features` → `/examples` → `/training` → `/docs/reference`
Success: supervised agent workflow with telemetry and failure controls.

**C) AI feature team** → `/features` → `/build/product-feature-blueprints` → `/docs/guides/ai-chat-agent` → `/docs/guides/retries-backpressure-and-failure-recovery`
Success: first feature shipped with readiness checklist.

**D) Platform/SRE track** → `/docs/production-readiness-checklist` → `/docs/reference` → `/docs/security-and-governance` → `/docs/guides`
Success: approved runbook/alerting baseline and safe upgrade path.

### Cross-cutting content for non-Elixir personas

1. Why Elixir/OTP for agent workloads — written for polyglot outsiders, not BEAM insiders.
2. Mixed-stack integration blueprints (TS/Python/JVM/.NET boundaries).
3. Migration-without-rewrite playbooks.
4. Security and governance center (tool permissions, threat model, audit posture).

---

## 8) Voice, Tone & Style

### Register

Technical and direct. Write for a senior engineer evaluating tools on a weekday, not a conference keynote audience. Show before tell — code examples, architecture diagrams, concrete behavior over abstract claims.

### POV

Address the reader as "you." Reference teams as "teams" or "your team." Jido is "Jido" on first use per page, then "it" or "the runtime."

### Sound like

- A thoughtful staff engineer explaining an architecture decision to a peer.
- Confident in what we've built but honest about tradeoffs.
- Specific over vague. "Supervision restarts crashed agents" over "built-in resilience."

### Do not sound like

- Marketing copy that could describe any product. No "unlock the power of" or "supercharge your workflow."
- Insider shorthand. Write "Elixir/OTP's process isolation" not "let it crash" without context.
- Breathless hype. No "revolutionary," "game-changing," or "the future of."

### Technical depth by section

- **Features / Ecosystem:** Concept-first, then one code example per capability. Enough to evaluate, not implement.
- **Build / Docs:** Code-first. Show implementation, then explain why.
- **Training:** Pedagogical. Build incrementally. Every code block runnable.
- **Community:** Outcome-first. Show what teams achieved and how.

### Avoided phrases

- "Unlock the power of" / "supercharge" / "turbocharge"
- "Revolutionary" / "game-changing" / "the future of"
- "Simply" / "just" / "easily"
- "Production-ready" without specific evidence
- "Best-in-class" / "world-class" / "enterprise-grade"
- "Let it crash" without explaining what it means
- "Users" — say "you" or "teams" instead

### Terminology & capitalization

- **Jido** — always capitalized in prose (lowercase only in code/package names)
- **BEAM** — always all-caps
- **OTP** — always all-caps
- **Elixir/OTP** — compound form for platform advantage
- **LiveView** — capital L, capital V
- **GenServer** — capital G, capital S
- **multi-agent** — hyphenated as adjective
- **runtime-first** — hyphenated as compound adjective
- **fault-tolerant** — hyphenated
- **open-source** — hyphenated as adjective, "open source" as noun
- **hex.pm** — lowercase
- **agentjido.xyz** — lowercase
- **HexDocs** — capital H, capital D

### Jido-specific terms (always capitalize when referring to Jido concepts)

Action, Signal, Directive, Agent, Sensor, Plugin, Strategy

Lowercase: workflow, runtime (general concepts, not Jido-specific types)

### Headings

Sentence case. Exception: proper nouns and Jido-specific terms stay capitalized.

### Code example rules

- Realistic module/function names, never `Foo` or `MyApp`
- Under 30 lines inline; link to full examples for longer code
- Always show result/output, not just setup
- Prefer Jido ecosystem packages (`jido`, `jido_ai`, `jido_action`, `jido_signal`)
- Language tag on all code blocks: `elixir`, `bash`, `json`, etc.
- `iex>` prefix for interactive examples, `$` for shell commands
- Hex format for deps: `{:jido, "~> 1.0"}`

### Link rules

- Internal: relative paths (`/docs/guides/...`)
- Packages: `https://hex.pm/packages/jido`
- API: `https://hexdocs.pm/jido`
- Ecosystem overview: agentjido.xyz
- Never link to internal workspace files, GitHub source, or contributor-only paths in public content

### Status labels

- **Stable** — API settled, suitable for production
- **Beta** — functional and usable, API may change
- **Experimental** — early development, expect breaking changes
- **Planned** — not yet implemented

Always include status on ecosystem/package pages. Never describe experimental packages with production-confidence language.

### Structural conventions

- Bullet lists for 3+ items; prose for 1-2
- Tables for comparisons and structured data
- Admonitions (`> **Note:**`, `> **Warning:**`, `> **Tip:**`) sparingly — max 2 per page
- Every page needs a clear "what's next" link at the bottom
- Prerequisites at the top

### CTA convention

- Default: **Get Building**
- Section alternatives: "Start Training", "Explore Features", "See the Ecosystem"
- CTA must always link to a real, populated destination

---

## 9) Content Architecture Rules

### Site IA narrative

| Section | User question answered |
|---|---|
| Features | What capabilities matter and why? |
| Ecosystem | Which package solves which architecture layer? |
| Build | How do I implement this now? |
| Training | How do I level up quickly? |
| Docs | Where are exact APIs/configs/migration details? |
| Community | How are other teams using this? |

Storyline: `Features → Ecosystem → Build → Training → Docs → Community`

### Strategic page contract (every major page must include)

1. A clear claim.
2. A concrete architecture explanation.
3. One runnable proof surface.
4. One training cross-link.
5. One docs/reference cross-link.
6. `Get Building` CTA.

### Required conversion cross-links

- Features → Ecosystem → Build
- Features → Examples → Training
- Training → Docs
- Ecosystem packages → Build quickstarts → Training modules
- Features/Docs/Training → Get Building

### Editorial posture

- Practical, technical, and testable.
- Confident but not hype-driven.
- Honest about tradeoffs and adoption cost.

---

## 10) Ecosystem Package Map

### Runtime & coordination core
`jido`, `jido_action`, `jido_signal`

### Intelligence & model layer
`jido_ai`, `req_llm`, `llm_db`, `jido_claude`

### Tools & execution layer
`jido_browser`, `jido_code`, `jido_sandbox`, `jido_runic`, `jido_behaviortree`, `jido_live_dashboard`, `jido_shell`, `jido_vfs`

### Integrations & deployment layer
`ash_jido`, `jido_messaging`, `jido_flame`, `agent_jido`

---

## 11) Governance & Anti-Hallucination Rules

### Proof-backed claims

Every positioning claim must connect to a concrete package, example, or reference. If a claim has no proof, soften it ("designed for…" not "delivers…") or remove it.

### Known proof gaps (do not imply these exist)

- Zero operational demos (failure drills, dashboard walkthroughs, trace narratives)
- Zero purpose-built reference docs (runbooks, telemetry catalogs, SRE checklists)
- Zero architecture diagrams
- Many content plan briefs exist, but most pages are draft/stub — pipeline exists, content does not
- Training modules exist but coverage depth varies

### Publishing hard gates (ST-CONT-001)

1. **No placeholders.** No "TODO", "TBD", "Coming soon", or draft markers in published content.
2. **Route/link reality.** All links and CTAs must resolve to currently routable, populated pages. No links to planned-but-unbuilt pages.
3. **Proof alignment.** Claims about reliability, performance, adoption, or production readiness must link to concrete proof assets.
4. **Code accuracy.** Snippets must match current APIs, modules, and signatures.
5. **Package references are real.** Every package named must exist in `priv/ecosystem/*.md` with `visibility: public`.

### Freshness mindset

Content drifts from code. Avoid absolute claims without evidence. Status labels must be accurate to current maturity.

---

## 12) Canonical Copy Blocks

### CTA options

1. Get Building
2. Start Training
3. Explore Features
4. See the Ecosystem
5. Build Your First Agent

### 10-second pitch

`Jido is a runtime for reliable, multi-agent systems.`

### 30-second pitch

`Jido is a runtime for reliable, multi-agent systems. Built on Elixir/OTP, it gives teams fault-tolerant concurrency, explicit multi-agent coordination, and operational tooling to run safely under real load.`

### 2-minute pitch

`Most teams can prototype agents quickly, but production is where systems break. Jido is built for that reality. Jido is a runtime for reliable, multi-agent systems, built on Elixir/OTP for fault-tolerant concurrency and production-grade reliability. Agent behavior is explicit, coordinated, and observable: actions define capabilities, signals handle communication, directives model orchestration, and OTP supervision provides failure containment and recovery. Instead of optimizing only for day-one speed, Jido optimizes for day-100 reliability. That makes it a strong fit for teams building serious multi-agent products that must keep working when traffic, complexity, and operational pressure increase.`

---

## 13) Documentation Writing Principles

Adapted from direct-response copywriting for technical library docs:

1. **Channel existing need.** Developers arrive with problems. Show how Jido solves what they're already trying to solve.
2. **The headline consumes 80% of adoption potential.** First line must pass the 5-second test.
3. **Every sentence earns the next.** If a sentence can be skipped without loss, cut it.
4. **Specificity = credibility.** "Supervision restarts crashed agents" not "built-in resilience."
5. **API design beats documentation.** Fix the API before polishing prose.
6. **Show the "after" state first.** Open with what their code looks like, then explain how to get there.
7. **Enter the conversation in their head.** Start where the developer IS, not where you want them to be.
8. **She's your colleague, not a moron.** Don't over-explain basics. Tell the truth about limitations.
9. **Test your documentation.** Clone fresh. Follow the quickstart. Do examples compile?
10. **Write to one developer, never "users."** Use "you" naturally.

### Ecosystem documentation layers

| Layer | Artifacts | Audience |
|---|---|---|
| Package (HexDocs) | README, module docs, function docs | External dev installing from hex.pm |
| Cross-package (agentjido.xyz) | Getting started, tutorials, architecture overviews | Developer evaluating the ecosystem |
| Contributor (internal) | AGENTS.md, workspace docs | Contributors only — never published |

**Routing rule:** API details → HexDocs. Ecosystem tutorials → agentjido.xyz. Contributor workflows → internal only.

**No internal leakage:** Never mention `jido_dep/4`, `mix ws.*`, workspace commands, or internal paths in public docs.

### The "So what?" test

After every feature claim, ask "So what?" until you hit developer value. Lead with the final answer, support with technical details.

---

## 14) Content Pipeline (for writing repo content)

### How content works

All site content is static Markdown in `priv/`. At compile time, NimblePublisher reads each file, extracts Elixir-map frontmatter (NOT YAML), validates against a Zoi schema, and compiles to module attributes.

Frontmatter format:
```elixir
%{
  title: "My Page Title",
  tags: [:agents, :tutorial],
  status: :draft
}
---
Markdown body starts here.
```

### Content directories

| Directory | Route | Count |
|---|---|---|
| `priv/blog/` | `/blog/:slug` | 4 posts |
| `priv/ecosystem/` | `/ecosystem/:id` | 19 packages |
| `priv/training/` | `/training/:slug` | 6 modules |
| `priv/examples/` | `/examples/:slug` | 2 examples |
| `priv/documentation/` | `/docs/:slug`, `/cookbook/:slug` | varies |
| `priv/pages/features/` | `/features/:slug` | 7 (stub/draft) |
| `priv/pages/build/` | `/build/:slug` | 5 (stub/draft) |
| `priv/pages/community/` | `/community/:slug` | 4 (stub/draft) |
| `priv/content_plan/` | Not rendered | Internal briefs |

### Specs → priv relationship

`specs/` = strategy, constraints, specifications.
`priv/` = actual content that gets rendered.
Specs govern what goes into priv.

### For AI agents writing content

1. Check `style-voice.md` for tone, terminology, mechanics
2. Check `content-outline.md` for where content fits in IA
3. Check `templates/` for structural template for page type
4. Use frontmatter schema from the relevant schema module
5. Cross-reference `priv/ecosystem/*.md` for package claims
6. Check `priv/content_plan/` for editorial brief if one exists
7. Validate against governance §10 before publishing
8. Use `proof.md` to verify claims have backing evidence

---

## 15) Positioning Checklist (before publishing any major page)

1. Does the page reinforce the runtime-first thesis?
2. Does it explain why BEAM matters in practical terms?
3. Does it include concrete multi-agent proof, not generic AI language?
4. Does it map to a persona and next-step journey?
5. Does it connect to training and reference documentation?

---

## 16) Current Reality Constraints

- Features/Build/Community page pipelines exist but content is **draft/stub**.
- Training modules exist with varying depth.
- Docs pipeline migrated to `priv/pages/docs/` — most outlined docs pages are missing.
- No package-matrix route yet.
- Proof inventory shows zero operational demos, zero reference docs, zero architecture diagrams.
- Content plan briefs exist for most gaps — the work is converting briefs to finished assets.
- Ecosystem: 2 stable, 3 beta, 12 experimental, 2 planned packages.
