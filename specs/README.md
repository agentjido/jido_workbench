# Site Strategy & Content Specs

Last updated: 2026-02-19

This folder is the authoritative home for site positioning, content strategy, and messaging governance.

## Core Positioning (Current Anchor)

- Anchor phrase: `Jido is a runtime for reliable, multi-agent systems.`
- Differentiator: `Built on Elixir/OTP for fault-tolerant concurrency and production-grade reliability.`
- Primary CTA convention: `Get Building`
- Hero headline (locked): `A runtime for reliable, multi-agent systems.`
- Hero subhead (locked): `Design, coordinate, and operate agent workflows that stay stable in production — built on Elixir/OTP for fault isolation, concurrency, and uptime.`
- Target nav (locked): `Features | Ecosystem | Examples | Training | Docs | Community | Get Building`

## Document Index

### Positioning & Messaging

- `positioning.md` — Core positioning strategy, narrative system, differentiation framing, persona coverage, messaging pillars, and copy system.
- `style-voice.md` — Voice, tone, terminology, and style/mechanical conventions for all site content.
- `proof.md` — Proof inventory mapping messaging pillars to concrete evidence assets.

### Content Architecture

- `content-outline.md` — Site information architecture, page inventory, section outline, and delivery phases.
- `persona-journeys.md` — Persona clusters, buyer intent stages, canonical journeys, and conversion signals.
- `content-system.md` — Content pipeline reference — where content lives in `priv/`, frontmatter schemas, compile-time flow, and route mapping.

### Governance & Quality

- `content-governance.md` — Content quality controls, validation pipeline, publish gates, and operating model. Includes canonical ST-CONT-001 publish hard gate (§11) and freshness/release cadence checklist (§12).
- `docs-manifesto.md` — Documentation writing principles adapted from direct response copywriting for Elixir library ecosystems.

### Templates

- `templates/` — Page template skeletons for each content type:
  - `feature-page.md`, `build-guide.md`, `docs-concept.md`, `docs-reference.md`, `ecosystem-package.md`, `training-module.md`

### Task Tracking

- `TODO.md` — Pre-writing prep task tracker with priority and effort estimates.

### Competitive Research

- `competitors/` — Deep-dive competitor briefings for the top 10 agentic frameworks (AutoGen, LlamaIndex, CrewAI, Semantic Kernel, LangGraph, Haystack, Mastra, Google ADK, PydanticAI, Sagents).
- `competitors/external_agentic_framework_feature_matrix.md` — Normalized feature matrix across all frameworks.

### Runbooks

- `runbooks/admin_bootstrap_runbook.md` — Admin user bootstrap and verification procedures.
- `runbooks/chatops_runbook.md` — ChatOps subsystem startup and health validation.
- `runbooks/chatops_durability_decision.md` — Architecture decision record for messaging durability.
- `runbooks/release_punchlist.md` — Homepage-down release checklist, quality gates, and page review matrix.

### Brainstorms

- `brainstorms/content-agents.md` — ContentOps agent system design (v2) — multi-agent content factory brainstorm.
- `brainstorms/mintlify_gaps/` — Mintlify feature gap analysis for the docs site platform.

## Content Pipeline

All site content is static Markdown compiled at build time via NimblePublisher with Zoi schema validation. See `content-system.md` for the full reference.

### Source directories (priv/)

| Directory | Purpose | Schema module | Rendered? |
|---|---|---|---|
| `priv/blog/` | Blog posts | `AgentJido.Blog.Post` | ✅ `/blog/:slug` |
| `priv/ecosystem/` | Package metadata | `AgentJido.Ecosystem.Package` | ✅ `/ecosystem/:id` |
| `priv/training/` | Training curriculum | `AgentJido.Training.Module` | ✅ `/training/:slug` |
| `priv/examples/` | Interactive demos | `AgentJido.Examples.Example` | ✅ `/examples/:slug` |
| `priv/documentation/` | Docs & guides | `AgentJido.Documentation.Document` | ✅ `/docs/...` |
| `priv/content_plan/` | Editorial briefs | `AgentJido.ContentPlan.Entry` | ❌ Internal |

### Relationship: specs/ → priv/

`specs/` contains strategy, constraints, and specifications.  
`priv/` contains the actual content that gets rendered.  
`lib/agent_jido/` contains the schema modules that define the contract between them.

Specs govern what goes into priv/. `content-system.md` maps the full pipeline.

## Working Agreement

- Keep claims proof-backed (example + training + docs/reference path).
- Keep top-level language broad and clear.
- Use Elixir/OTP as explicit differentiator language, not insider shorthand.
- Keep the project posture OSS-first; default CTAs should drive self-serve builder onboarding.
- Update the `Last updated` line when materially changing strategy.
