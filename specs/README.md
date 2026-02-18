# Marketing Strategy Docs

Last updated: 2026-02-12

This folder is the persistent home for site strategy and messaging work papers.

## Core Positioning (Current Anchor)

- Anchor phrase: `Jido is a runtime for reliable, multi-agent systems.`
- Differentiator: `Built on Elixir/OTP for fault-tolerant concurrency and production-grade reliability.`
- Primary CTA convention: `Get Building`
- Hero headline (locked): `A runtime for reliable, multi-agent systems.`
- Hero subhead (locked): `Design, coordinate, and operate agent workflows that stay stable in production — built on Elixir/OTP for fault isolation, concurrency, and uptime.`
- Target nav (locked): `Features | Ecosystem | Examples | Training | Docs | Community | Get Building`

## Document Index

- `marketing/positioning.md`
  - Full positioning strategy, narrative system, differentiation framing, and messaging copy.
- `marketing/content-outline.md`
  - High-level information architecture and headline/content outline for the site.
- `marketing/persona-journeys.md`
  - Persona clusters, buyer intent stages, canonical journeys, and conversion signals.
- `marketing/content-governance.md`
  - Content quality controls, validation pipeline, and operating model for keeping site content in sync with ecosystem source truth.
  - Canonical ST-CONT-001 publish hard gate: content DoD (§11) and freshness/release cadence checklist (§12).
- `marketing/style-voice.md`
  - Voice, tone, and style/mechanical conventions guide for all site content.
- `marketing/proof.md`
  - Proof inventory mapping messaging pillars to concrete evidence assets.
- `marketing/TODO.md`
  - Pre-writing prep task tracker.
- `marketing/templates/`
  - Page template skeletons for each content type (feature, ecosystem, build, training, docs-concept, docs-reference).
- `marketing/docs-manifesto.md`
  - Documentation writing principles adapted from direct response copywriting for Elixir library ecosystems.
- `marketing/content-system.md`
  - Content pipeline reference — where content lives in `priv/`, frontmatter schemas, compile-time flow, and route mapping. Essential context for AI agents.

## Content Pipeline

All site content is static Markdown compiled at build time via NimblePublisher with Zoi schema validation. See `marketing/content-system.md` for the full reference.

### Source directories (priv/)

| Directory | Purpose | Schema module | Rendered? |
|---|---|---|---|
| `priv/blog/` | Blog posts | `AgentJido.Blog.Post` | ✅ `/blog/:slug` |
| `priv/ecosystem/` | Package metadata | `AgentJido.Ecosystem.Package` | ✅ `/ecosystem/:id` |
| `priv/training/` | Training curriculum | `AgentJido.Training.Module` | ✅ `/training/:slug` |
| `priv/examples/` | Interactive demos | `AgentJido.Examples.Example` | ✅ `/examples/:slug` |
| `priv/documentation/` | Docs & guides | `AgentJido.Documentation.Document` | ✅ `/docs/...` |
| `priv/content_plan/` | Editorial briefs | `AgentJido.ContentPlan.Entry` | ❌ Internal |

### Relationship: marketing/ → priv/

`marketing/` contains strategy, constraints, and specifications.  
`priv/` contains the actual content that gets rendered.  
`lib/agent_jido/` contains the schema modules that define the contract between them.

Marketing docs govern what goes into priv/. Content-system.md maps the full pipeline.

## Working Agreement

- Keep claims proof-backed (example + training + docs/reference path).
- Keep top-level language broad and clear.
- Use Elixir/OTP as explicit differentiator language, not insider shorthand.
- Keep the project posture OSS-first; default CTAs should drive self-serve builder onboarding.
- Update the `Last updated` line when materially changing strategy.
