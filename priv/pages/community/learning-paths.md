%{
  title: "Learning Paths",
  category: :community,
  description: "Guided learning paths from beginner to production-ready agent developer.",
  doc_type: :guide,
  audience: :beginner,
  draft: false,
  order: 10
}
---
Learning paths reduce random exploration by pairing one objective with one proof checkpoint.
Each path below maps to content that is already routable in this repository.

## How these paths were built

These paths are derived from current training modules, docs pages, and runnable examples:

- Training routes under [/training](/training)
- Docs routes under [/docs](/docs)
- Examples under [/examples](/examples)

If any link or module moves, update this page in the same release window.

## Role-based paths

### Path A: Elixir platform engineer

- Primary goal: run and supervise one production-shaped agent workflow.
- Start module: [Agent Fundamentals on the BEAM](/training/agent-fundamentals)
- Proof checkpoint: [Counter Agent example](/examples/counter-agent)
- Next step: [Reference Architectures](/build/reference-architectures)

### Path B: AI product engineer

- Primary goal: ship one user-facing workflow with explicit actions and validation.
- Start module: [Actions and Validation](/training/actions-validation)
- Proof checkpoint: [Demand Tracker Agent example](/examples/demand-tracker-agent)
- Next step: [Product Feature Blueprints](/build/product-feature-blueprints)

### Path C: Staff architect / tech lead

- Primary goal: define rollout boundaries and governance before broad adoption.
- Start module: [Production Readiness: Supervision, Telemetry, and Failure Modes](/training/production-readiness)
- Proof checkpoint: [Architecture](/docs/architecture)
- Next step: [Adoption Playbooks](/community/adoption-playbooks)

### Path D: Platform and SRE engineer

- Primary goal: establish observability, incident response, and review cadence.
- Start module: [Signals and Routing](/training/signals-routing)
- Proof checkpoint: [Incident Playbooks](/docs/incident-playbooks)
- Next step: [Case Studies](/community/case-studies)

## Completion criteria

A path is complete when the learner can provide:

1. One runnable proof link (example, test, or validation step).
2. One architecture or governance reference link.
3. One documented next step for team rollout.

## Get Building

Pick one role path, finish one proof checkpoint this week, and document follow-up actions in [Adoption Playbooks](/community/adoption-playbooks).
