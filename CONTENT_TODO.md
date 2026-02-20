# Top-Down Content Audit + Home/Features Rewrite Plan (Planning Only)

No code/content edits in this step. This is a single planning document.

## 1) Objective
Run a top-down content audit of major public pages (starting at `/`), then prepare a full rewrite plan for Home and all Features pages, aligned to positioning and voice strategy across all priority audiences.

## 2) Hard Constraints
1. Keep primary nav unchanged in `/Users/mhostetler/Source/Jido/agentjido_xyz/lib/agent_jido_web/components/jido/nav.ex`.
2. Do not add Build, Training, or Community to primary nav.
3. Treat all Features content as rewriteable.
4. Anchor strategy to:
- `/Users/mhostetler/Source/Jido/agentjido_xyz/specs/README.md`
- `/Users/mhostetler/Source/Jido/agentjido_xyz/specs/positioning.md`
- `/Users/mhostetler/Source/Jido/agentjido_xyz/specs/style-voice.md`
- `/Users/mhostetler/Source/Jido/agentjido_xyz/specs/content-outline.md`
- `/Users/mhostetler/Source/Jido/agentjido_xyz/specs/proof.md`

## 3) Major Content Items To Highlight

### 3.1 Positioning non-negotiables
1. Anchor: "Jido is a runtime for reliable, multi-agent systems."
2. Differentiator: Elixir/OTP runtime semantics (fault isolation, supervision, concurrency).
3. Intelligence posture: model-agnostic runtime where LLM usage is optional (`jido_ai`/`req_llm` are add-on layers, not a core requirement).
4. Four narrative pillars:
- Reliability by architecture
- Coordination you can reason about
- Operations and observability
- Composable incremental adoption
5. Narrative contrast: prototype-first vs runtime-first (fit-for-purpose, non-hostile framing).
6. Audience coverage requirement: each pillar and feature page must state "who this is for" (Elixir builders, AI product engineers, polyglot evaluators, SRE/platform, security/compliance, decision-makers).
7. Proof discipline: each strategic page must connect to ecosystem package(s), runnable example(s), and docs reference(s).
8. Primary CTA convention: `Get Building`.

### 3.2 Feature categories to showcase ecosystem power

These are feature categories (not single features). Each category needs concrete capability callouts and proof links.

| Category | Concrete capabilities to highlight | Ecosystem packages to spotlight | First proof surfaces | Primary audiences |
|---|---|---|---|---|
| Runtime reliability and lifecycle control | `Jido.AgentServer`, OTP supervision, restart semantics, process isolation, parent/child Agent lifecycles | `jido`, `jido_live_dashboard` | Counter Agent, Demand Tracker, production-readiness docs | Elixir platform, SRE/platform, staff architect |
| Deterministic state transitions and typed capabilities | `cmd/2` contract, Action schema validation, directive-based effects, testable pure logic | `jido`, `jido_action` | Counter Action snippets, actions-validation training | AI product engineers, Elixir builders |
| Signal routing and multi-agent coordination | CloudEvents-aligned Signals, route tables, adapter-based dispatch, replay/history | `jido_signal`, `jido_action`, `jido` | signals-routing training, demand tracker routes | AI product engineers, architects, polyglot evaluators |
| Strategy-based orchestration (classical + runtime strategies) | direct/FSM strategies, behavior-tree strategy, DAG workflow strategy, schedules/cron directives | `jido`, `jido_behaviortree`, `jido_runic` | directives-scheduling training, workflow strategy examples | Advanced builders, architects, AI engineers |
| Tool execution and safe automation | tool Actions, browser/code/file workflows, sandboxed execution patterns, timeout/retry controls | `jido_browser`, `jido_code`, `jido_vfs`, `jido_sandbox`, `jido_shell`, `jido_action` | tool-response docs/livebooks, example guides | AI product engineers, security/compliance, polyglot teams |
| LLM-optional intelligence layer | ask/await workflows, model aliasing, strategy-driven reasoning, verification/reflection pipeline | `jido_ai`, `req_llm`, `llm_db`, `jido_claude`, `jido_gemini` | AI chat/tool-calling guides, `jido_ai` ecosystem page | AI engineers, product teams, decision-makers |
| Operations and observability | telemetry events, distributed trace context, dashboard runtime inspection, incident workflows | `jido_live_dashboard`, `jido_otel`, `jido` | dashboard walkthroughs, readiness checklist, incident playbooks | SRE/platform, architects, engineering leads |
| Integration and incremental adoption | bounded pilot approach, mixed-stack boundaries, messaging integration, phased package adoption | `ash_jido`, `jido_messaging`, `agent_jido` | mixed-stack guide, package matrix, first-agent path | polyglot evaluators, EM/CTO, staff architects |

### 3.3 Audience map (all audiences must be represented)

| Audience | What they need to see quickly | Feature categories to emphasize first |
|---|---|---|
| Elixir platform engineer | OTP alignment and deterministic runtime model | Runtime reliability, deterministic state transitions, operations |
| AI product engineer | Safe tool-calling workflows under load | Coordination, tool execution, LLM-optional intelligence |
| Staff architect / tech lead | Migration path and architecture boundaries | Incremental adoption, runtime reliability, orchestration strategies |
| Python/TS evaluator | Why this runtime fits mixed stacks | Incremental adoption, coordination, model-agnostic posture |
| SRE/platform engineer | Observable failure modes and clear controls | Operations/observability, runtime lifecycle control |
| Security/compliance engineer | Tool risk boundaries and governance posture | Tool execution safety, operations, adoption constraints |
| Engineering manager / CTO | Risk-managed rollout and ROI logic | Executive summary framing across all categories |

### 3.4 Feature card contract (for every feature mention on Home/Features)
1. Capability name (specific, not generic pillar text).
2. What problem it solves (single operational problem statement).
3. Runtime mechanism (how it works in Jido).
4. Package proof (`/ecosystem/...`) and status label (Stable/Beta/Experimental/Planned).
5. Runnable proof (example or snippet with expected output).
6. Audience fit line ("Best for ...").
7. Next step link to docs/training/examples.

### 3.5 Messaging anti-patterns to avoid
1. Do not collapse the ecosystem into "LLM framework" language.
2. Do not present maturity-unclear packages as production defaults.
3. Do not use capability claims without an adjacent proof path.
4. Do not mix persona journeys with feature taxonomy (separate sections).

## 4) Audit Scope (Top-Down)
Audit these URLs in order:
1. `/`
2. `/features`
3. `/features/*`
4. `/ecosystem`
5. `/examples`
6. `/docs`
7. `/getting-started`
8. `/blog`

Scoring dimensions per page (0-3):
1. Positioning alignment
2. Voice/style compliance
3. Proof density
4. Audience clarity
5. CTA quality
6. Cross-link coherence
7. Intelligence posture clarity (runtime-first, LLM-optional, non-LLM examples present)
8. Ecosystem depth clarity (does the page reveal package depth beyond `jido` + `jido_ai`?)
9. Maturity clarity (Stable/Beta/Experimental labels visible where needed)

## 5) Home Page Reframe Plan (`/`)
Target file (for future implementation):
`/Users/mhostetler/Source/Jido/agentjido_xyz/lib/agent_jido_web/live/jido_home_live.ex`

Planned section order:
1. Locked hero (keep locked headline/subhead intact).
2. Runtime POV ("prototype output vs production operation").
3. Model posture block ("LLM-optional runtime" + non-LLM workflow examples).
4. Four-pillar grid linking to feature pillars.
5. Feature-category strip ("what the ecosystem includes") with 6-8 category cards.
6. Why Elixir/OTP credibility block.
7. Proof rail (ecosystem + examples + docs grouped by category).
8. Audience quick paths (Elixir platform, AI product, architect/SRE, polyglot evaluators, security/compliance, technical decision-makers).
9. CTA cluster.

Home proof rail rules:
1. Include at least one non-LLM proof path above the fold.
2. Include one advanced strategy proof path (behavior tree or workflow DAG).
3. Include one operations proof path (dashboard/telemetry).
4. Include one incremental-adoption proof path (single Agent pilot).

CTA map:
1. Primary: `/docs/getting-started`
2. Secondary: `/features`
3. Tertiary: `/ecosystem`

## 6) Features Hub Rewrite Plan (`/features`)
Target file (for future implementation):
`/Users/mhostetler/Source/Jido/agentjido_xyz/lib/agent_jido_web/live/jido_features_live.ex`

Planned hub sections:
1. Category claim aligned to positioning anchor.
2. Intelligence architecture map (runtime core + optional LLM layer + classical decision layers).
3. Four-pillar architecture map.
4. Category explorer cards (problem + mechanism + package proof).
5. Differentiation panel (runtime-first vs prototype-first).
6. Audience selectors.
7. Proof jump panel (ecosystem + example + docs).
8. Maturity labels and adoption guidance panel ("start here", "evaluate next", "experimental").
9. Final CTA (`Get Building`).

Features hub card requirements:
1. Every card names 1-2 packages.
2. Every card links to a runnable proof and one docs/training path.
3. Every card states audience fit.

## 7) Features Subpage Rewrite Contract (`/features/*`)
Target files (for future implementation):
`/Users/mhostetler/Source/Jido/agentjido_xyz/priv/pages/features/*.md`

Apply same structure to all 7 pages:
1. Claim
2. Engineering problem
3. Runtime mechanism
4. Capability breakdown (3-6 concrete capabilities)
5. Package mapping with status labels
6. Concrete proof snippet + expected output
7. Tradeoffs/non-goals
8. Audience fit + adoption guidance
9. Next-step links (ecosystem + examples + docs + training)
10. Get Building CTA

Page mapping:
1. `reliability-by-architecture` -> Pillar 1 + runtime lifecycle category
2. `multi-agent-coordination` -> Pillar 2 + signal coordination category
3. `operations-observability` -> Pillar 3 + ops category
4. `incremental-adoption` -> Pillar 4 + integration category
5. `beam-for-ai-builders` -> Elixir/OTP support thesis + model-agnostic/LLM-optional clarity
6. `jido-vs-framework-first-stacks` -> Differentiation framing
7. `executive-brief` -> Decision-maker summary with risk/ROI and phased adoption

## 8) Deliverable Artifacts (Planning Phase)
Produce these docs before any rewrite implementation:
1. Top-down audit report (scores + findings + priorities).
2. Feature taxonomy matrix (pillars -> categories -> capabilities -> packages -> proof links).
3. Audience map (persona -> first categories -> first proof path -> first CTA).
4. Home rewrite blueprint (section intent + required links + acceptance checklist).
5. Features hub rewrite blueprint.
6. Features subpage contract doc.

## 9) Acceptance Criteria
1. Plan explicitly preserves primary nav as-is.
2. Home and Features plans align to positioning/voice docs.
3. All 7 feature pages use one normalized contract.
4. Every planned feature page includes proof snippet + expected output.
5. CTA strategy is consistent and routable.
6. Cross-link strategy includes ecosystem, examples, docs.
7. Home and Features explicitly communicate LLM-optional architecture and include at least one non-LLM example path.
8. Feature navigation includes clear routes for all priority persona clusters.
9. Feature taxonomy includes concrete capabilities, package mappings, and maturity labels.
10. At least one showcased path exists for each major ecosystem layer (core runtime, coordination, tooling, intelligence, operations, integration).

## 10) Implementation Sequence (When You Approve Execution)
1. Finalize audit report.
2. Finalize feature taxonomy matrix.
3. Finalize audience map.
4. Finalize Home blueprint.
5. Finalize Features hub blueprint.
6. Finalize subpage contract.
7. Implement Home.
8. Implement Features hub.
9. Rewrite all 7 feature pages.
10. Run targeted tests and link checks.
11. Review against voice/style + proof checklist.
