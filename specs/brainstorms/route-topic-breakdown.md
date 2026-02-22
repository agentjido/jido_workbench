# Route-First Topic Breakdown

Date: 2026-02-22
Status: Companion view to `consolidated-topic-breakdown.md`

---

## Scope

This plan covers content under **`/docs`** only. The primary nav is:

**Home · Features · Ecosystem · Examples · Docs**

`/features` has its own route tree — see `features-route-breakdown.md` for that. `/ecosystem` and `/examples` are handled by dedicated LiveViews. All three are excluded from this breakdown.

`/build`, `/training`, and `/community` are **not** top-level nav items — they are folded into `/docs` as sections. All content routes in this plan live under `/docs/*`.

---

## How routing works

The Pages system (`AgentJido.Pages`) drives all content routes. For `:docs` category pages, the URL is the page's `path` field verbatim (e.g., `/docs/guides/testing-agents-and-actions`). The docs sidebar groups pages by **section** — the first path segment after `/docs/` (e.g., `concepts`, `guides`, `learn`). Each section needs a root page at `/docs/<section>` that serves as the section hub.

Content files live in `priv/pages/docs/` and the file tree mirrors the URL structure.

---

## Route Tree

### `/docs` — Top-level entry points

| Route | Title | Status | Priority | Source theme |
|---|---|---|---|---|
| `/docs` | Docs Overview | outline | P0 | — |
| `/docs/getting-started` | Getting Started | outline | P0 | Theme 1 |

These are the two pages a user hits first. Getting-started routes into the learn section below.

---

### `/docs/learn` — Tutorials and progressive build guides

> Consolidates the former `/build` and `/training` trees. The progression is: installation → first-agent → first-llm-agent → first-workflow, then structured training modules, then deeper build guides.

#### Onboarding ladder (Theme 1)

| Route | Title | Status | Priority | Old route | Notes |
|---|---|---|---|---|---|
| `/docs/learn` | Learn Hub | — | P0 | — | New section root; routes into onboarding ladder and training modules |
| `/docs/learn/installation` | Installation and Setup | review | P0 | `/build/installation` | |
| `/docs/learn/first-agent` | Build Your First Agent (no LLM) | review | P0 | `/build/first-agent` | Guide 1 |
| `/docs/learn/first-llm-agent` | `[NEW]` Build Your First LLM Agent | — | P0 | — | Guide 2 |
| `/docs/learn/first-workflow` | `[NEW]` Build Your First Workflow | — | P0 | — | Guide 3 |
| `/docs/learn/why-not-just-a-genserver` | `[NEW]` Why Not Just a GenServer? | — | P1 | — | Bridge piece |
| `/docs/learn/quickstarts-by-persona` | Quickstarts by Persona | outline | P1 | `/build/quickstarts-by-persona` | |

#### Training modules (Theme 14)

| Route | Title | Status | Priority | Old route |
|---|---|---|---|---|
| `/docs/learn/agent-fundamentals` | Agent Fundamentals on the BEAM | published | — | `/training/agent-fundamentals` |
| `/docs/learn/actions-validation` | Actions and Schema Validation | published | — | `/training/actions-validation` |
| `/docs/learn/signals-routing` | Signals, Routing, and Agent Communication | published | — | `/training/signals-routing` |
| `/docs/learn/directives-scheduling` | Directives, Scheduling, and Time-Based Behavior | published | — | `/training/directives-scheduling` |
| `/docs/learn/liveview-integration` | LiveView and Jido Integration Patterns | published | — | `/training/liveview-integration` |
| `/docs/learn/production-readiness` | Production Readiness | published | — | `/training/production-readiness` |

#### Build guides (Theme 4)

| Route | Title | Status | Priority | Old route |
|---|---|---|---|---|
| `/docs/learn/counter-agent` | Counter Agent Example | published | — | `/build/counter-agent` |
| `/docs/learn/demand-tracker-agent` | Demand Tracker Agent Example | published | — | `/build/demand-tracker-agent` |
| `/docs/learn/behavior-tree-without-llm` | `[NEW]` Behavior Tree Workflows Without LLM | — | P1 | — |
| `/docs/learn/ai-chat-agent` | Build an AI Chat Agent | outline | P1 | `/build/ai-chat-agent` |
| `/docs/learn/tool-use` | Tool Use and Function Calling | outline | P1 | `/build/tool-use` |
| `/docs/learn/multi-agent-workflows` | Multi-Agent Workflows | outline | P1 | `/build/multi-agent-workflows` |
| `/docs/learn/mixed-stack-integration` | Mixed-Stack Integration | outline | P1 | `/build/mixed-stack-integration` |
| `/docs/learn/reference-architectures` | Reference Architectures | outline | P2 | `/build/reference-architectures` |
| `/docs/learn/product-feature-blueprints` | Product Feature Blueprints | outline | P2 | `/build/product-feature-blueprints` |

**25 pages** in `/docs/learn` (4 `[NEW]`). 8 published.

---

### `/docs/concepts` — Core primitives (Theme 2)

| Route | Title | Status | Priority |
|---|---|---|---|
| `/docs/concepts` | Core Concepts Hub | outline | P0 |
| `/docs/concepts/key-concepts` | Key Concepts | draft | P0 |
| `/docs/concepts/agents` | Agents | draft | P0 |
| `/docs/concepts/actions` | Actions | draft | P0 |
| `/docs/concepts/signals` | Signals | draft | P0 |
| `/docs/concepts/directives` | Directives | outline | P0 |
| `/docs/concepts/agent-runtime` | Agent Runtime (AgentServer) | draft | P0 |
| `/docs/concepts/plugins` | Plugins | outline | P1 |

**8 pages**. 0 published. All existing.

---

### `/docs/guides` — How-to guides and patterns (Themes 6, 8, 9, 10, 11)

| Route | Title | Status | Priority | Notes |
|---|---|---|---|---|
| `/docs/guides` | Guides Hub | outline | P1 | |
| `/docs/guides/retries-backpressure-and-failure-recovery` | Retries, Backpressure, and Failure Recovery | draft | P1 | |
| `/docs/guides/long-running-agent-workflows` | Long-Running Agent Workflows | outline | P1 | |
| `/docs/guides/persistence-memory-and-vector-search` | Persistence, Memory, and Vector Search | draft | P1 | |
| `/docs/guides/testing-agents-and-actions` | Testing Agents and Actions | draft | P1 | |
| `/docs/guides/troubleshooting-and-debugging-playbook` | Troubleshooting and Debugging Playbook | outline | P1 | |
| `/docs/guides/mcp-integration` | `[NEW]` MCP Integration Guide | — | P1 | Theme 9 |
| `/docs/guides/mixed-stack-runbooks` | Mixed-Stack Runbooks | outline | P2 | |
| `/docs/guides/cookbook` | Cookbook | outline | P2 | |
| `/docs/guides/cookbook/chat-response` | Cookbook: Chat Response | published | — | Already exists in `priv/pages` |
| `/docs/guides/cookbook/tool-response` | Cookbook: Tool Response | published | — | Already exists in `priv/pages` |
| `/docs/guides/cookbook/weather-tool-response` | Cookbook: Weather Tool Response | published | — | Already exists in `priv/pages` |

**12 pages** (1 `[NEW]`). 3 published (cookbook recipes).

---

### `/docs/operations` — Production ops and reliability (Themes 6, 7)

| Route | Title | Status | Priority |
|---|---|---|---|
| `/docs/operations` | Operations Hub | outline | P0 |
| `/docs/operations/production-readiness-checklist` | Production Readiness Checklist | outline | P0 |
| `/docs/operations/security-and-governance` | Security and Governance | outline | P0 |
| `/docs/operations/incident-playbooks` | Incident Playbooks | outline | P1 |
| `/docs/operations/backup-and-disaster-recovery` | `[NEW]` Backup and Disaster Recovery | — | P1 |

**5 pages** (1 `[NEW]`). 0 published.

---

### `/docs/reference` — API contracts, config, architecture (Themes 3, 5, 12)

| Route | Title | Status | Priority | Notes |
|---|---|---|---|---|
| `/docs/reference` | Reference Hub | outline | P0 | |
| `/docs/reference/architecture` | Architecture Overview | outline | P0 | |
| `/docs/reference/ai-integration-decision-guide` | `[NEW]` AI Integration Decision Guide | — | P0 | Theme 3 |
| `/docs/reference/provider-capability-and-fallback-matrix` | `[NEW]` Provider Capability and Fallback Matrix | — | P0 | Theme 5 |
| `/docs/reference/configuration` | Configuration Reference | draft | P0 | |
| `/docs/reference/architecture-decision-guides` | Architecture Decision Guides | outline | P1 | |
| `/docs/reference/telemetry-and-observability` | Telemetry and Observability Reference | draft | P1 | |
| `/docs/reference/data-storage-and-pgvector` | Data Storage and pgvector Reference | draft | P1 | |
| `/docs/reference/glossary` | Glossary | draft | P1 | |
| `/docs/reference/migrations-and-upgrade-paths` | Migrations and Upgrade Paths | outline | P2 | |
| `/docs/reference/content-governance-and-drift-detection` | Content Governance and Drift Detection | outline | P2 | |

**11 pages** (2 `[NEW]`). 0 published.

---

### `/docs/reference/packages` — Package API references (Theme 12)

| Route | Title | Status | Priority |
|---|---|---|---|
| `/docs/reference/packages/jido` | Package Reference: jido | outline | P0 |
| `/docs/reference/packages/jido-action` | Package Reference: jido_action | outline | P0 |
| `/docs/reference/packages/jido-signal` | Package Reference: jido_signal | outline | P0 |
| `/docs/reference/packages/jido-ai` | Package Reference: jido_ai | outline | P0 |
| `/docs/reference/packages/req-llm` | Package Reference: req_llm | outline | P0 |
| `/docs/reference/packages/jido-runic` | `[NEW]` Package Reference: jido_runic | — | P0 |
| `/docs/reference/packages/jido-browser` | Package Reference: jido_browser | outline | P1 |
| `/docs/reference/packages/agent-jido` | Package Reference: agent_jido | outline | P1 |
| `/docs/reference/packages/jido-memory` | `[NEW]` Package Reference: jido_memory | — | P1 |
| `/docs/reference/packages/jido-otel` | `[NEW]` Package Reference: jido_otel | — | P1 |
| `/docs/reference/packages/jido-behaviortree` | `[NEW]` Package Reference: jido_behaviortree | — | P1 |

**11 pages** (4 `[NEW]`). 0 published.

---

### `/docs/community` — Adoption enablement (Theme 13)

> Consolidates the former `/community` tree. Includes manager roadmap (moved from `/training`).

| Route | Title | Status | Priority | Old route |
|---|---|---|---|---|
| `/docs/community` | Community Hub | — | P2 | — |
| `/docs/community/adoption-playbooks` | Adoption Playbooks | outline | P2 | `/community/adoption-playbooks` |
| `/docs/community/case-studies` | Case Studies | planned | P2 | `/community/case-studies` |
| `/docs/community/learning-paths` | Learning Paths | outline | P2 | `/community/learning-paths` |
| `/docs/community/manager-roadmap` | Manager Adoption Roadmap | outline | P2 | `/training/manager-roadmap` |

**5 pages** (0 `[NEW]`). 0 published. All P2.

---

## Summary by section

| Section | Total | Published | `[NEW]` | P0 | P1 | P2 |
|---|---|---|---|---|---|---|
| `/docs` (hubs) | 2 | 0 | 0 | 2 | 0 | 0 |
| `/docs/learn` | 25 | 8 | 4 | 5 | 12 | 2 |
| `/docs/concepts` | 8 | 0 | 0 | 7 | 1 | 0 |
| `/docs/guides` | 12 | 3 | 1 | 0 | 7 | 2 |
| `/docs/operations` | 5 | 0 | 1 | 2 | 2 | 0 |
| `/docs/reference` | 11 | 0 | 2 | 4 | 4 | 2 |
| `/docs/reference/packages` | 11 | 0 | 4 | 6 | 5 | 0 |
| `/docs/community` | 5 | 0 | 0 | 0 | 0 | 5 |
| **Total under /docs** | **79** | **11** | **12** | **26** | **31** | **11** |

Features pages are tracked separately in `features-route-breakdown.md`.

---

## Docs sidebar sections (left nav)

The sidebar groups by section slug. After consolidation, a user clicking **Docs** in the primary nav sees these sections:

| Sidebar section | Section root | Page count |
|---|---|---|
| Getting Started | `/docs/getting-started` | 1 (standalone) |
| Learn | `/docs/learn` | 25 |
| Concepts | `/docs/concepts` | 8 |
| Guides | `/docs/guides` | 12 |
| Operations | `/docs/operations` | 5 |
| Reference | `/docs/reference` | 22 (incl. packages) |
| Community | `/docs/community` | 5 |

The secondary tabs at the top of the docs layout will show these 7 sections. `Getting Started` is a standalone page (no children in the sidebar), acting as the entry point that routes users into `Learn`.

---

## Migration: routes that move

These existing routes need legacy redirects to their new canonical paths:

### `/build/*` → `/docs/learn/*`

| Old route | New route |
|---|---|
| `/build` | `/docs/learn` |
| `/build/installation` | `/docs/learn/installation` |
| `/build/first-agent` | `/docs/learn/first-agent` |
| `/build/quickstarts-by-persona` | `/docs/learn/quickstarts-by-persona` |
| `/build/counter-agent` | `/docs/learn/counter-agent` |
| `/build/demand-tracker-agent` | `/docs/learn/demand-tracker-agent` |
| `/build/ai-chat-agent` | `/docs/learn/ai-chat-agent` |
| `/build/tool-use` | `/docs/learn/tool-use` |
| `/build/multi-agent-workflows` | `/docs/learn/multi-agent-workflows` |
| `/build/mixed-stack-integration` | `/docs/learn/mixed-stack-integration` |
| `/build/reference-architectures` | `/docs/learn/reference-architectures` |
| `/build/product-feature-blueprints` | `/docs/learn/product-feature-blueprints` |

### `/training/*` → `/docs/learn/*`

| Old route | New route |
|---|---|
| `/training/agent-fundamentals` | `/docs/learn/agent-fundamentals` |
| `/training/actions-validation` | `/docs/learn/actions-validation` |
| `/training/signals-routing` | `/docs/learn/signals-routing` |
| `/training/directives-scheduling` | `/docs/learn/directives-scheduling` |
| `/training/liveview-integration` | `/docs/learn/liveview-integration` |
| `/training/production-readiness` | `/docs/learn/production-readiness` |
| `/training/manager-roadmap` | `/docs/community/manager-roadmap` |

### `/community/*` → `/docs/community/*`

| Old route | New route |
|---|---|
| `/community` | `/docs/community` |
| `/community/adoption-playbooks` | `/docs/community/adoption-playbooks` |
| `/community/case-studies` | `/docs/community/case-studies` |
| `/community/learning-paths` | `/docs/community/learning-paths` |

---

## Ordering within `/docs/learn`

The learn section is the largest (25 pages) and needs explicit ordering to prevent a messy sidebar. Suggested order groups:

| Order range | Group | Pages |
|---|---|---|
| 10–19 | Onboarding ladder | installation, first-agent, first-llm-agent, first-workflow |
| 20–29 | Training modules | agent-fundamentals, actions-validation, signals-routing, directives-scheduling, liveview-integration, production-readiness |
| 30–39 | Bridge pieces | why-not-just-a-genserver, quickstarts-by-persona |
| 40–59 | Build examples | counter-agent, demand-tracker-agent, behavior-tree-without-llm, ai-chat-agent, tool-use, multi-agent-workflows |
| 60–79 | Advanced builds | mixed-stack-integration, reference-architectures, product-feature-blueprints |

---

## Open questions

1. **Should `/docs/learn` be flat or nested?** Currently proposed as flat (25 pages in one sidebar section). Could split into `/docs/learn/tutorials/*` and `/docs/learn/training/*` if the sidebar gets unwieldy. The Pages system supports nesting — but it means two more section roots to maintain.

2. **Cookbook nesting.** Three cookbook recipes already exist at `/docs/guides/cookbook/*`. The cookbook hub at `/docs/guides/cookbook` is their parent. This is the only 3-level nesting in docs today. Keep as-is or flatten?

3. **`/docs/getting-started` as standalone vs section.** Currently proposed as a standalone page outside any section. Alternative: make it the root of `/docs/learn` and rename the section "Getting Started & Learn". Risk: the sidebar title gets long and the section becomes even larger.

4. **Legacy redirect mechanism.** The Pages system already supports `legacy_paths` per page. The migration table above should be implemented via that field, not manual router entries.
