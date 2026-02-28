# Lovable Prompt: Jido Homepage Redesign (Positioning-Aligned)

Use this as the full prompt in Lovable. Build a production-grade homepage redesign for Jido using the structure and quality bar from Mastra, CrewAI, and LangGraph, while staying strictly aligned to Jido positioning.

---

## Role and Objective

You are a senior product UX/UI designer and front-end system thinker.

Redesign the Jido homepage (`/`) to:
- look and feel closer to the best-in-class patterns from Mastra and LangGraph (with CrewAI section pacing),
- improve conversion and clarity for builders,
- preserve Jido's runtime-first differentiation and technical credibility,
- keep the **Ecosystem** section as a first-class section (do not remove it).

---

## Source-of-Truth Context (must follow)

Use these as hard constraints:
- `specs/positioning.md`
- `specs/competitors/jido-homepage-benchmark.md`
- `specs/competitors/07-mastra/homepage-outline.md`
- `specs/competitors/03-crewai/homepage-outline.md`
- `specs/competitors/05-langgraph/homepage-outline.md`

---

## Non-Negotiable Positioning Constraints

1. Keep this exact hero headline:
- `A runtime for reliable, multi-agent systems.`

2. Keep this exact supporting subhead:
- `Design, coordinate, and operate agent workflows that stay stable in production — built on Elixir/OTP for fault isolation, concurrency, and uptime.`

3. Preserve product thesis:
- runtime-first, reliability-first, production operations-first.
- Jido is for moving from fragile prototypes to production-grade multi-agent systems.

4. Keep tone and claims grounded:
- practical, technical, testable, not hype-heavy.
- do not use vague superlatives like “best framework.”

5. Product posture:
- open source and builder-first activation.
- CTAs should prioritize self-serve building and training.

---

## Benchmark-Driven Gaps to Solve

Solve these explicitly in the redesign:
- add top-of-page trust/proof strip (social proof and adoption signals),
- add high-visual concrete agent template/use-case cards,
- surface quickstart command directly in hero,
- add capability shortcut chips under hero CTA,
- reframe middle narrative into **Build -> Operate -> Scale**,
- add FAQ section before final CTA,
- add secondary enterprise/contact path without weakening OSS primary path.

---

## Required Homepage Architecture

Design the page in this order:

1. Header
- Primary nav: Features, Ecosystem, Examples, Docs.
- Include prominent primary CTA (Get Building or equivalent).
- If user-auth utility UI is present, visually minimize its dominance on marketing pages.

2. Hero
- Eyebrow: reliability/runtime framing.
- Locked H1 and locked subhead.
- Primary CTA: `Get Building`.
- Secondary CTA: `Explore Features`.
- Add an inline quickstart command block (use real command from docs/getting-started; do not invent).
- Add compact capability chips: Agents, Workflows, Signals, Actions, Supervision, Observability.

3. Trust / Proof Strip
- Include credibility metrics and/or logos.
- Prefer concrete proof: package count, stars, production teams, community activity, etc.

4. Agent Templates / Use-Case Grid (Mastra-style)
- 6 cards minimum with concrete outcomes.
- Example card themes:
  - Browser agent
  - Deep research
  - Coding assistant
  - Incident triage / ops copilot
  - Text-to-SQL analytics
  - Workflow coordinator
- Each card includes title + one-line value + “View example” action.

5. Build -> Operate -> Scale Narrative
- Three distinct bands/sections:
  - Build: explicit coordination primitives (actions/signals/directives).
  - Operate: observability, debugging, runbooks, incident control.
  - Scale: supervision, fault isolation, concurrency model.
- Keep language architecture-specific and evidence-backed.

6. Ecosystem Section (must keep)
- Keep as dedicated section, not merged away.
- Preserve package architecture framing and links.
- You may redesign visuals/layout for clarity and scan speed.
- Preserve the “composable/incremental adoption” message.

7. Quick Start Code Section
- Keep real code snippet and path to full docs.
- Improve visual hierarchy and readability.
- Include links to training and docs as clear next steps.

8. Why Elixir/OTP Section
- Keep the runtime-semantic argument:
  - process isolation
  - supervision/recovery
  - fault-tolerant concurrency
- Use concise architecture language, not generic marketing text.

9. FAQ (new)
- 5–7 questions to handle objections from positioning doc:
  - “We are not an Elixir shop.”
  - “Is this heavier than prototype-first frameworks?”
  - “How do we de-risk adoption?”
  - “Can this integrate with existing Python/TS systems?”
  - “How does Jido handle multi-agent coordination?”

10. Final CTA
- Dual path:
  - Primary: `Get Building`
  - Secondary: `Start Training` or `Contact` (enterprise path)
- Reinforce runtime reliability and production readiness.

11. Footer
- Keep company/resources/social/packages structure.
- Ensure docs/examples/training are highly discoverable.

---

## Content and Copy Guardrails

Must reinforce these positioning pillars:
- Reliability by architecture.
- Multi-agent coordination you can reason about.
- Production operations and observability.
- Composable ecosystem and incremental adoption.

Must not imply:
- “Jido solves all AI architecture problems.”
- benchmarkless performance promises.
- anti-competitor attack copy.

Use respectful differentiation framing:
- prototype-first tools optimize initial setup,
- Jido optimizes reliable long-term operation.

---

## Visual Direction

Design language target:
- contemporary, technical, conversion-ready.
- blend Mastra’s concrete visual examples with LangGraph’s reliability/control clarity.

Styling guidance:
- high-contrast, purposeful typography, clean spacing rhythm.
- strong hierarchy and scannable section transitions.
- subtle motion only where meaningful (hero reveal, card hover, stagger entry).
- avoid generic “AI blob” aesthetic; emphasize engineering confidence and runtime control.

---

## UX / Interaction Requirements

- Desktop + mobile responsive behavior.
- Sticky header with clear CTA visibility.
- Fast first-screen comprehension (value prop + action within 5 seconds).
- Card layouts accessible and keyboard navigable.
- CTA hierarchy consistent across sections.

---

## Deliverables

Provide:
1. Redesigned homepage layout and component structure.
2. Proposed copy per section (headline + body + CTA labels).
3. Mobile-first adaptations for key sections.
4. A short rationale mapping each section to:
- benchmark influence (Mastra/CrewAI/LangGraph),
- Jido positioning alignment.

---

## Acceptance Checklist

The redesign is successful only if all are true:
- Hero uses locked headline and locked subhead exactly.
- Ecosystem section remains present and substantive.
- Trust/proof strip added near top.
- Concrete template/use-case card grid added.
- Build/Operate/Scale narrative exists.
- FAQ added before final CTA.
- Final CTA includes both builder-first and secondary enterprise/training path.
- Page feels closer to Mastra/LangGraph quality while preserving Jido’s reliability-first identity.

