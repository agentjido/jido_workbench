%{
  title: "Adoption Playbooks",
  category: :community,
  description: "Strategies for introducing Jido into your team and organization.",
  doc_type: :guide,
  audience: :intermediate,
  draft: false,
  order: 20
}
---
Adoption playbooks are decision records, not slide decks.
Use them to ship one bounded workflow, capture evidence, and expand only after review criteria pass.

## Evidence and attribution rules

This page summarizes patterns observed in this repository's shipped assets:

- Runtime and release controls in [Production Readiness Checklist](/docs/reference/production-readiness-checklist)
- Coordination and execution patterns in [Directives and Scheduling](/training/directives-scheduling)
- Concrete implementation references in [Build with Jido](/build/build)

No external customer metrics are asserted in this playbook.

## Playbook 1: Pilot one workflow in one team

- Scope: single workflow, single owner, single success metric.
- Required proof: one runnable demo and one rollback plan.
- Review links: [Counter Agent](/examples/counter-agent), [Security and Governance](/docs/reference/security-and-governance)

Exit criteria:

1. Workflow executes predictably for one sprint.
2. Failure behavior is documented.
3. Incident ownership is explicit.

## Playbook 2: Expand to adjacent workflows

- Scope: add one neighboring workflow that reuses existing runtime boundaries.
- Required proof: signal/action contracts and incident path updates.
- Review links: [Signals and Routing](/training/signals-routing), [Incident Playbooks](/docs/reference/incident-playbooks)

Exit criteria:

1. Shared boundaries are explicit and reviewed.
2. New workflow has clear non-goals.
3. Rollback path is tested before release.

## Playbook 3: Section-level publish readiness

- Scope: move documentation and training references from draft to publish-ready.
- Required proof: ST-CONT-001 checks completed.
- Review links: [Content Governance](/docs/reference/security-and-governance), [Case Studies](/community/case-studies)

Exit criteria:

1. No placeholder markers remain.
2. Route/content parity is verified.
3. Reviewer sign-off and date are recorded.

## Operating cadence

- Weekly: triage adoption blockers and stale references.
- Biweekly: approve `draft: false` transitions that pass DoD checks.
- Monthly: run a section sweep for drift and missing proof links.

## Get Building

Choose one playbook, time-box the first milestone, and pair it with one learning route from [Learning Paths](/community/learning-paths).
