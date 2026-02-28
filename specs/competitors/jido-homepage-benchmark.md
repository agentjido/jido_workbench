# Jido Homepage Benchmark vs Mastra, CrewAI, and LangGraph

Reviewed: 2026-02-25
Jido homepage reviewed: http://localhost:4000/
Comparison baselines:
- `specs/competitors/07-mastra/homepage-outline.md`
- `specs/competitors/03-crewai/homepage-outline.md`
- `specs/competitors/05-langgraph/homepage-outline.md`

## Current Jido homepage structure (observed)

1. Utility/account bar (signed-in state), then primary nav.
2. Hero with clear reliability-focused headline and two CTAs.
3. "Why Jido" value section with four feature cards.
4. Ecosystem package map/cards.
5. Quick start code section.
6. "Why Elixir/OTP" technical rationale section.
7. Final CTA section.
8. Footer with company/resources/social/packages.

## Element-by-element comparison

| Best-in-class element | Mastra | CrewAI | LangGraph | Jido status | Gap and recommendation |
|---|---|---|---|---|---|
| Focused marketing header with product + proof + CTA | Strong | Strong | Strong | Partial | Keep nav, but reduce top-page friction from signed-in utility bar on marketing view. |
| Hero with crisp positioning + primary/secondary CTA | Strong | Strong | Strong | Present | Solid; keep the reliability angle. |
| Hero quickstart command / "start now" friction reducer | Strong | Medium | Medium | Partial | Quick start exists lower on page; surface install command in hero like Mastra. |
| Immediate capability shortcuts (agents/workflows/tools/etc.) | Strong | Medium | Medium | Missing | Add short capability chip row under hero CTA. |
| Trust/logo band near top | Medium | Strong | Strong | Missing | Add social proof strip directly under hero (users, repos, stars, logos). |
| Concrete template/use-case cards (high-visual) | Strong | Medium | Medium | Missing | Add a 6-card example grid (e.g., browser agent, deep research, coding agent, text-to-sql). |
| Platform narrative progression (build -> operate -> scale) | Strong | Strong | Strong | Partial | Current sections are feature-first; reframe as staged journey across 3 bands. |
| Reliability and control narrative (HITL, workflows, memory, streaming) | Medium | Medium | Strong | Partial | Reliability is strong; add explicit sections for workflow control, memory/state, and streaming UX. |
| Customer proof / adoption momentum section | Medium | Strong | Medium | Missing | Add customer stories or ecosystem adoption metrics block. |
| Educational bridge (tutorials/academy) | Medium | Medium | Strong | Partial | Training/docs links exist but are buried; add dedicated learning strip. |
| FAQ / objections section | Weak | Weak | Strong | Missing | Add FAQ section to answer architecture and adoption objections. |
| Bottom conversion block (start + sales/contact) | Medium | Strong | Strong | Partial | Current CTA supports builders; add secondary enterprise/contact path. |

## Where Jido is already strong

1. Clear technical positioning around reliability and OTP supervision.
2. Concrete quick-start code with realistic agent snippets.
3. Ecosystem depth shown explicitly (package architecture is credible).

## Highest-impact changes to look more like Mastra + LangGraph

1. Add a visual "Agent templates" grid directly after the hero.
2. Add a trust/proof band under the hero (logos, adoption metrics, repos).
3. Move quickstart command into hero; keep full code block lower.
4. Reframe middle page into three narrative sections: Build, Operate, Scale.
5. Add a short FAQ section before final CTA.
6. Add a second CTA path for enterprise/contact while preserving OSS self-serve.

## Suggested revised section order for Jido homepage

1. Header
2. Hero (value prop + install command + 2 CTAs)
3. Trust/proof strip
4. Agent templates card grid
5. Build / Operate / Scale narrative sections
6. Reliability deep dive (OTP-specific claims)
7. Quick start code block
8. FAQ
9. Final CTA (Get Started + Contact)
10. Footer
