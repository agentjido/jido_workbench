%{
  title: "Case Studies",
  category: :community,
  description: "Real-world stories of teams building production agent systems with Jido.",
  doc_type: :explanation,
  audience: :beginner,
  draft: false,
  order: 30
}
---
Case studies in this section are implementation narratives tied to verifiable repository assets.
Each case is scoped to what can be observed directly in source, docs, and runnable examples.

## Permission and publication policy

Each case study in this page has explicit publication permission for this repository.
Permission scope for each entry: maintainer-approved, technical-summary-only, no confidential customer data.

If an external team case is added later, written approval and attribution must be recorded before publish.

## Case study 1: Counter workflow onboarding

- Context: onboarding engineers needed a minimal supervised workflow to learn state transitions.
- Implementation asset: [Counter Agent example](/examples/counter-agent)
- Supporting training/doc links: [Agent Fundamentals on the BEAM](/training/agent-fundamentals), [Core Concepts](/docs/concepts)
- Proof signal: deterministic state updates from bounded actions.
- Permission: approved by repository maintainers for documentation use.

## Case study 2: Demand workflow coordination pattern

- Context: teams needed an event-driven example that showed signals plus directive emission.
- Implementation asset: [Demand Tracker Agent example](/examples/demand-tracker-agent)
- Supporting training/doc links: [Signals and Routing](/training/signals-routing), [Architecture](/docs/reference/architecture)
- Proof signal: explicit action execution plus emitted directive data.
- Permission: approved by repository maintainers for documentation use.

## Case study 3: Content release governance rollout

- Context: content waves required consistent publish gating before `draft: false` transitions.
- Implementation asset: [Adoption Playbooks](/community/adoption-playbooks)
- Supporting training/doc links: [Production Readiness: Supervision, Telemetry, and Failure Modes](/training/production-readiness), [Production Readiness Checklist](/docs/operations/production-readiness-checklist)
- Proof signal: story-scoped tests validate placeholder removal and draft-state transitions.
- Permission: approved by repository maintainers for documentation use.

## How to author the next case study

1. Identify the bounded workflow and business context.
2. Link one runnable proof asset and two supporting references.
3. Record permission and attribution before publication.
4. Document non-goals so readers understand scope.

## Get Building

Use [Learning Paths](/community/learning-paths) to choose a path, then capture one rollout narrative with [Adoption Playbooks](/community/adoption-playbooks).
