# Jido Proof Inventory

Version: 1.0  
Last updated: 2026-02-12  
Primary inputs: `specs/positioning.md` §9 (Messaging Pillars), §7 (Persona Coverage), §8 (Ecosystem Proof Architecture)

> **Purpose:** Map every positioning claim to concrete, verifiable proof. If a cell is empty, the claim is unsupported. Fill this in before publishing any major page.
>
> **Rule from positioning.md §8:** Every pillar must reference at least one package, one runnable example, and one training module.

---

## Pillar 1: Reliability by Architecture

> _Core message: Agents should fail safely and recover predictably._

| Proof type | Asset name / description | Location | Status | Notes |
|---|---|---|---|---|
| Training module | Agent Fundamentals — lifecycle, supervision basics | `priv/training/agent-fundamentals.md` | 🟡 partial | TODO: Confirm failure-recovery coverage depth |
| Training module | Production Readiness — operational hardening | `priv/training/production-readiness.md` | 🟡 partial | TODO: Does it include failure drill walkthroughs? |
| Runnable example | Counter Agent — basic agent lifecycle demo | `lib/agent_jido/demos/counter/counter_agent.ex` | ✅ exists | Needs review: does it demo crash/restart? |
| Content plan brief | Supervision and Fault Isolation feature page | `priv/content_plan/features/supervision-and-fault-isolation.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Retries, Backpressure, and Failure Recovery | `priv/content_plan/operate/retries-backpressure-and-failure-recovery.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Incident Playbooks | `priv/content_plan/operate/incident-playbooks.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Production Readiness Checklist | `priv/content_plan/operate/production-readiness-checklist.md` | 🟡 partial | Brief exists; page not built |
| Ecosystem doc | `jido` core package — supervision primitives | `priv/ecosystem/jido.md` | ✅ exists | TODO: Verify supervision API coverage |
| Runnable example | **Failure drill demo** — kill agent, watch recovery | _TODO: create_ | ❌ missing | High priority. Best single proof for this pillar |
| Operational demo | **Supervision tree visualization** — LiveDashboard showing agent restarts | _TODO: create_ | ❌ missing | Could use `jido_live_dashboard` |
| Code snippet | Supervisor config for multi-agent tree | _TODO: create or extract_ | ❌ missing | Short, copy-pasteable snippet |
| Reference doc | **Production runbook** — restart procedures, escalation paths | _TODO: create_ | ❌ missing | Maps to SRE persona need |
| Architecture diagram | Agent supervision tree diagram | _TODO: create_ | ❌ missing | Visual proof for architect persona |

### Pillar 1 — Package coverage check

| Package | Role in this pillar | Proof referenced above? |
|---|---|---|
| `jido` | Core supervision, agent lifecycle | ✅ |
| `jido_live_dashboard` | Supervision visibility | ❌ TODO: create demo |
| `jido_flame` | Elastic scaling under failure | ❌ TODO: document |

---

## Pillar 2: Multi-Agent Coordination You Can Reason About

> _Core message: Complex agent behavior should be explicit and testable._

| Proof type | Asset name / description | Location | Status | Notes |
|---|---|---|---|---|
| Training module | Signals & Routing — inter-agent communication | `priv/training/signals-routing.md` | ✅ exists | TODO: Confirm multi-agent scenario coverage |
| Training module | Directives & Scheduling — orchestration patterns | `priv/training/directives-scheduling.md` | ✅ exists | TODO: Confirm testability examples |
| Training module | Actions & Validation — typed capability model | `priv/training/actions-validation.md` | ✅ exists | |
| Runnable example | Demand Tracker Agent — multi-step workflow | `lib/agent_jido/demos/demand/demand_tracker_agent.ex` | ✅ exists | TODO: Does it show multi-agent coordination? |
| LiveView example | Demand Tracker LiveView | `lib/agent_jido_web/examples/demand_tracker_agent_live.ex` | ✅ exists | Interactive proof |
| Content plan brief | Signal Routing and Coordination feature page | `priv/content_plan/features/signal-routing-and-coordination.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Directives and Scheduling feature page | `priv/content_plan/features/directives-and-scheduling.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Multi-Agent Workflows build guide | `priv/content_plan/build/multi-agent-workflows.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Schema-Validated Actions feature page | `priv/content_plan/features/schema-validated-actions.md` | 🟡 partial | Brief exists; page not built |
| Ecosystem doc | `jido_signal` — signal routing primitives | `priv/ecosystem/jido_signal.md` | ✅ exists | |
| Ecosystem doc | `jido_action` — typed action model | `priv/ecosystem/jido_action.md` | ✅ exists | |
| Runnable example | **Signal routing demo** — two agents passing structured signals | _TODO: create_ | ❌ missing | Key proof gap |
| Runnable example | **Directive composition demo** — chain/parallel/conditional | _TODO: create_ | ❌ missing | Shows "reasonability" claim |
| Operational demo | **Workflow trace visualization** — step-by-step signal/action flow | _TODO: create_ | ❌ missing | Could pair with telemetry pillar |
| Code snippet | Signal schema definition + dispatch example | _TODO: create or extract_ | ❌ missing | |
| Code snippet | Directive definition with test assertion | _TODO: create or extract_ | ❌ missing | Proves "testable" claim directly |
| Architecture diagram | Multi-agent signal flow diagram | _TODO: create_ | ❌ missing | |

### Pillar 2 — Package coverage check

| Package | Role in this pillar | Proof referenced above? |
|---|---|---|
| `jido_signal` | Signal routing | ✅ |
| `jido_action` | Typed actions | ✅ |
| `jido` | Directives, strategies | ✅ |
| `jido_behaviortree` | Complex decision flows | ❌ TODO: create example |
| `jido_runic` | Rule-based coordination | ❌ TODO: create example |

---

## Pillar 3: Production Operations and Observability

> _Core message: Real systems need telemetry, debugging workflows, and controls._

| Proof type | Asset name / description | Location | Status | Notes |
|---|---|---|---|---|
| Training module | Production Readiness — ops hardening | `priv/training/production-readiness.md` | ✅ exists | TODO: Verify telemetry content depth |
| Runnable example | Counter Agent LiveView — live operational surface | `lib/agent_jido_web/examples/counter_agent_live.ex` | ✅ exists | TODO: Does it show telemetry/metrics? |
| Content plan brief | Production Telemetry feature page | `priv/content_plan/features/production-telemetry.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Troubleshooting and Debugging Playbook | `priv/content_plan/operate/troubleshooting-and-debugging-playbook.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Agent Server operate guide | `priv/content_plan/operate/agent-server.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Testing Agents and Actions | `priv/content_plan/operate/testing-agents-and-actions.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Security and Governance | `priv/content_plan/operate/security-and-governance.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Long-Running Agent Workflows | `priv/content_plan/operate/long-running-agent-workflows.md` | 🟡 partial | Brief exists; page not built |
| Ecosystem doc | `jido_live_dashboard` — agent dashboard plugin | `priv/ecosystem/jido_live_dashboard.md` | ✅ exists | Key proof package |
| Operational demo | **Dashboard instrumentation walkthrough** — metrics, counters, traces | _TODO: create_ | ❌ missing | Highest-priority proof for this pillar |
| Operational demo | **Trace narrative** — "follow a request through 3 agents" | _TODO: create_ | ❌ missing | Story-driven proof |
| Reference doc | **SRE checklist** — deploy, monitor, alert, respond | _TODO: create_ | ❌ missing | Maps to SRE persona |
| Reference doc | **Telemetry event catalog** — all emitted events, fields, units | _TODO: create_ | ❌ missing | Reference-grade proof |
| Code snippet | `:telemetry` handler setup for agent events | _TODO: create or extract_ | ❌ missing | |
| Code snippet | LiveDashboard configuration for agent metrics | _TODO: create or extract_ | ❌ missing | |
| Architecture diagram | Observability stack diagram (app → telemetry → dashboard/export) | _TODO: create_ | ❌ missing | |

### Pillar 3 — Package coverage check

| Package | Role in this pillar | Proof referenced above? |
|---|---|---|
| `jido_live_dashboard` | Agent visibility | ✅ |
| `jido` | Telemetry emission | 🟡 implied, needs explicit proof |
| `jido_shell` | Interactive debugging | ❌ TODO: create example |
| `jido_sandbox` | Safe execution environment | ❌ TODO: document |

---

## Pillar 4: Composable Ecosystem with Incremental Adoption

> _Core message: Adopt only what you need now, expand safely later._

| Proof type | Asset name / description | Location | Status | Notes |
|---|---|---|---|---|
| Training module | Agent Fundamentals — minimal starting point | `priv/training/agent-fundamentals.md` | ✅ exists | |
| Training module | LiveView Integration — layer on UI | `priv/training/liveview-integration.md` | ✅ exists | Shows incremental adoption path |
| Content plan brief | Installation quickstart | `priv/content_plan/build/installation.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | First Agent guide | `priv/content_plan/build/first-agent.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Quickstarts by Persona | `priv/content_plan/build/quickstarts-by-persona.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Composable Ecosystem feature page | `priv/content_plan/features/composable-ecosystem.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Mixed-Stack Integration build guide | `priv/content_plan/build/mixed-stack-integration.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Reference Architectures | `priv/content_plan/build/reference-architectures.md` | 🟡 partial | Brief exists; page not built |
| Ecosystem docs | Full ecosystem package documentation | `priv/ecosystem/*.md` (19 packages) | ✅ exists | Foundation for package matrix |
| Reference doc | **Package matrix** — what each package does, dependencies, adoption order | _TODO: create_ | ❌ missing | Central proof for this pillar |
| Runnable example | **Minimal-stack quickstart** — `jido` only, no AI, no LiveView | _TODO: create_ | ❌ missing | Proves "adopt only what you need" |
| Runnable example | **Progressive adoption demo** — start with 1 package, add 3 more | _TODO: create_ | ❌ missing | Story-driven proof |
| Reference doc | **Migration guide** — from prototype to production-grade setup | _TODO: create_ | ❌ missing | Staff architect persona need |
| Reference doc | **Dependency map** — visual of which packages depend on which | _TODO: create_ | ❌ missing | |
| Architecture diagram | Ecosystem layer diagram (core → intelligence → tools → integrations) | _TODO: create_ | ❌ missing | Matches §8 structure |

### Pillar 4 — Package coverage check

| Package | Role in this pillar | Proof referenced above? |
|---|---|---|
| `jido` | Core, minimal starting point | ✅ |
| `jido_ai` | Intelligence layer add-on | 🟡 ecosystem doc exists, needs quickstart |
| `jido_action` | Standalone action package | 🟡 ecosystem doc exists, needs quickstart |
| `ash_jido` | Ash integration path | ❌ TODO: create adoption example |
| `jido_messaging` | Event bus integration | ❌ TODO: create adoption example |
| `agent_jido` | Full workbench reference app | ✅ (this repo is the proof) |

---

## Cross-Cutting Proof

These assets support multiple pillars and multiple personas simultaneously.

| Proof type | Asset name / description | Location | Status | Notes |
|---|---|---|---|---|
| Content plan brief | BEAM for AI Builders — why Elixir/OTP matters | `priv/content_plan/why/beam-for-ai-builders.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Executive Brief — decision-maker overview | `priv/content_plan/why/executive-brief.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | Jido vs Framework-First Stacks | `priv/content_plan/why/jido-vs-framework-first-stacks.md` | 🟡 partial | Brief exists; page not built |
| Reference doc | **Why BEAM comparison** — Elixir/OTP vs Python/Node runtime semantics | _TODO: create_ | ❌ missing | Python AI engineer persona |
| Runnable example | **Mixed-stack integration demo** — Jido backend + JS/Python client | _TODO: create_ | ❌ missing | TS fullstack + Python personas |
| Reference doc | **Migration-without-rewrite playbook** — adopt Jido alongside existing stack | _TODO: create_ | ❌ missing | Staff architect persona |
| Reference doc | **API boundary spec** — REST/gRPC/WebSocket surface for non-Elixir clients | _TODO: create_ | ❌ missing | Polyglot persona proof |
| Content plan brief | Product Feature Blueprints | `priv/content_plan/build/product-feature-blueprints.md` | 🟡 partial | Brief exists; page not built |
| Content plan brief | AI Chat Agent build guide | `priv/content_plan/build/ai-chat-agent.md` | 🟡 partial | Brief exists; page not built |
| Ecosystem doc | `jido_ai` — AI/LLM integration layer | `priv/ecosystem/jido_ai.md` | ✅ exists | |
| Ecosystem doc | `req_llm` — unified LLM client | `priv/ecosystem/req_llm.md` | ✅ exists | |

---

## Persona-Specific Proof Requirements

_Sourced from positioning.md §7 — Persona-level promise map._

### 1. Elixir Platform Engineer

> Promise: "Agent systems aligned with OTP discipline"  
> First proof needed: Supervision and failure-pattern examples

| Required proof | Mapped to pillar | Asset exists? | Location |
|---|---|---|---|
| Supervision tree examples with agent processes | Pillar 1 | ❌ missing | _TODO_ |
| Failure-pattern catalog (crash, timeout, overload) | Pillar 1 | ❌ missing | _TODO_ |
| OTP-idiomatic agent design patterns | Pillar 1 + 2 | 🟡 partial | `priv/training/agent-fundamentals.md` — needs review |
| LiveDashboard agent visibility | Pillar 3 | ❌ missing | _TODO: jido_live_dashboard demo_ |

### 2. AI Product Engineer

> Promise: "Ship AI features without runtime fragility"  
> First proof needed: End-to-end tool-calling examples

| Required proof | Mapped to pillar | Asset exists? | Location |
|---|---|---|---|
| End-to-end tool-calling example (LLM → action → result) | Pillar 2 | ❌ missing | _TODO_ |
| AI chat agent walkthrough | Pillar 2 + 4 | 🟡 partial | `priv/content_plan/build/ai-chat-agent.md` (brief only) |
| LiveView integration for AI features | Pillar 4 | ✅ exists | `priv/training/liveview-integration.md` |
| `jido_ai` + `req_llm` quickstart | Pillar 4 | ❌ missing | _TODO_ |

### 3. Staff Architect / Tech Lead

> Promise: "Adoption path with governance and maintainability"  
> First proof needed: Reference architectures and migration playbooks

| Required proof | Mapped to pillar | Asset exists? | Location |
|---|---|---|---|
| Reference architecture document | Pillar 4 | 🟡 partial | `priv/content_plan/build/reference-architectures.md` (brief only) |
| Migration playbook (existing stack → Jido) | Pillar 4 | ❌ missing | _TODO_ |
| Package dependency / governance map | Pillar 4 | ❌ missing | _TODO_ |
| Executive brief | Cross-cutting | 🟡 partial | `priv/content_plan/why/executive-brief.md` (brief only) |

### 4. Python AI Engineer

> Promise: "Better runtime semantics for long-lived workloads"  
> First proof needed: Why-BEAM comparison and interoperability guide

| Required proof | Mapped to pillar | Asset exists? | Location |
|---|---|---|---|
| Why BEAM for AI — compared to Python runtime | Cross-cutting | 🟡 partial | `priv/content_plan/why/beam-for-ai-builders.md` (brief only) |
| Interoperability guide (Python ↔ Jido) | Cross-cutting | ❌ missing | _TODO_ |
| Performance/concurrency comparison (practical, not benchmarketing) | Cross-cutting | ❌ missing | _TODO_ |

### 5. TypeScript Fullstack Engineer

> Promise: "Stable backend for JS product surfaces"  
> First proof needed: API boundary and frontend integration examples

| Required proof | Mapped to pillar | Asset exists? | Location |
|---|---|---|---|
| API boundary examples (REST/WebSocket from JS client) | Cross-cutting | ❌ missing | _TODO_ |
| Mixed-stack integration guide | Cross-cutting | 🟡 partial | `priv/content_plan/build/mixed-stack-integration.md` (brief only) |
| Frontend ↔ agent communication patterns | Pillar 2 + 4 | ❌ missing | _TODO_ |

### 6. Platform / SRE Engineer

> Promise: "Operable system with clear SLO signals"  
> First proof needed: Telemetry model, runbooks, incident patterns

| Required proof | Mapped to pillar | Asset exists? | Location |
|---|---|---|---|
| Telemetry event catalog | Pillar 3 | ❌ missing | _TODO_ |
| Production runbooks | Pillar 1 + 3 | ❌ missing | _TODO_ |
| Incident pattern library | Pillar 3 | 🟡 partial | `priv/content_plan/operate/incident-playbooks.md` (brief only) |
| SLO definition guide for agent systems | Pillar 3 | ❌ missing | _TODO_ |
| `jido_live_dashboard` SRE walkthrough | Pillar 3 | ❌ missing | _TODO_ |

---

## Summary Scorecard

| Pillar | Training modules | Runnable examples | Operational demos | Reference docs | Architecture diagrams |
|---|---|---|---|---|---|
| 1 — Reliability | 🟡 2 partial | 🟡 1 exists, 1 missing | ❌ 0 | ❌ 0 | ❌ 0 |
| 2 — Coordination | ✅ 3 exist | 🟡 1 exists, 2 missing | ❌ 0 | ❌ 0 | ❌ 0 |
| 3 — Operations | 🟡 1 partial | 🟡 1 exists | ❌ 0 | ❌ 0 | ❌ 0 |
| 4 — Composable | ✅ 2 exist | ❌ 0 purpose-built | ❌ 0 | ❌ 0 | ❌ 0 |

**Honest assessment:** Training module briefs and ecosystem docs provide a foundation, but there are zero operational demos, zero purpose-built reference docs, and zero architecture diagrams. The proof is light across every pillar. Content plan briefs exist for most gaps — the work is converting briefs into finished assets.

---

## Priority TODO List

_Ranked by positioning impact × effort._

1. ❌ **Failure drill demo** (Pillar 1) — Single most impactful proof for reliability claim
2. ❌ **Signal routing multi-agent demo** (Pillar 2) — Proves coordination is real
3. ❌ **Dashboard instrumentation walkthrough** (Pillar 3) — Proves observability is real
4. ❌ **Package matrix** (Pillar 4) — Foundational reference for composability claim
5. ❌ **Minimal-stack quickstart** (Pillar 4) — Proves incremental adoption
6. ❌ **Why BEAM comparison** (Cross-cutting) — Unlocks Python/TS persona journeys
7. ❌ **Telemetry event catalog** (Pillar 3) — SRE persona table stakes
8. ❌ **Production runbook** (Pillar 1 + 3) — Operability proof
9. ❌ **Mixed-stack integration demo** (Cross-cutting) — Polyglot persona proof
10. ❌ **End-to-end tool-calling example** (Pillar 2) — AI product engineer entry point

---

_This document is a living inventory. Update status columns as assets are created. Every ❌ is a positioning claim without proof._
