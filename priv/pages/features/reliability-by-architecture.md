%{
  title: "Reliability by Architecture",
  category: :features,
  description: "How Jido's OTP foundation provides fault isolation, supervision, and recovery by default.",
  doc_type: :explanation,
  audience: :intermediate,
  draft: false,
  order: 10
}
---
Jido treats reliability as an architectural constraint, not a patch you add later. Agent behavior stays deterministic in `cmd/2`, while OTP supervision handles process lifecycle and failure recovery.

## The problem

Many agent stacks are easy to demo but fragile under real load. Once workflows become long-lived and concurrent, teams end up writing custom restart logic, ad-hoc retry code, and one-off incident playbooks.

That approach creates two classes of failures:

- A single unhealthy workflow can affect unrelated work.
- Runtime recovery behavior is hard to reason about before an incident.

## How Jido addresses this

Jido separates decision logic from runtime execution:

- Agent state transitions happen in `cmd/2`, which keeps behavior explicit and testable.
- `Jido.AgentServer` runs agents inside OTP processes, so failures are isolated to process boundaries.
- Supervision strategy is part of your deployment topology, not hidden in application glue code.

This gives you a clear model:

1. Write deterministic agent logic.
2. Run it under supervised OTP processes.
3. Observe and operate it with repeatable runbooks.

## Proof: see it work

The workbench starts a production agent runtime under supervision in `AgentJido.Application`.

```elixir
children = [
  {Jido.AgentServer,
   id: AgentJido.ContentOps.OrchestratorServer,
   agent: AgentJido.ContentOps.OrchestratorAgent,
   jido: AgentJido.Jido,
   name: AgentJido.ContentOps.OrchestratorServer}
]

Supervisor.start_link(children, strategy: :one_for_one)
```

**Result:**

```
{:ok, #PID<...>}
```

The runtime process is now managed by OTP supervision and can be restarted according to your supervision strategy when it exits.

You can also inspect a concrete runtime-oriented example in [Demand Tracker Agent](/examples/demand-tracker-agent), which runs via `Jido.AgentServer` and scheduled signals.

## How this differs

Prototype-first frameworks often put reliability behavior in app-level conventions: retries in one service, timeout handling in another, and runbooks that are disconnected from runtime structure.

Jido starts from runtime structure first. Agent behavior, process boundaries, and supervision are explicit parts of the system model, which makes recovery behavior easier to test and operate.

## Learn more

- **Ecosystem:** [Jido package overview](/ecosystem/jido) and [Jido Live Dashboard](/ecosystem/jido_live_dashboard)
- **Training:** [Production Readiness: Supervision, Telemetry, and Failure Modes](/training/production-readiness)
- **Docs:** [Production Readiness Checklist](/docs/production-readiness-checklist) and [Architecture](/docs/architecture)
- **Context:** [All feature pillars](/features)

## Get Building

Ready to apply this in your own service? [Get Building](/getting-started), then validate your rollout with the [production checklist](/docs/production-readiness-checklist).
