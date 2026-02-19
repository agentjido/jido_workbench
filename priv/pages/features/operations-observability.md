%{
  title: "Operations & Observability",
  category: :features,
  description: "Built-in telemetry, metrics, tracing, and debugging for production agent systems.",
  doc_type: :explanation,
  audience: :intermediate,
  draft: false,
  order: 30
}
---
Jido is designed for teams that need to operate agents after launch. Telemetry, runtime inspection, and debugging surfaces are part of the operating model, not a separate afterthought.

## The problem

Agent systems fail in ways that are hard to diagnose if you only have logs and request traces. Without stable telemetry and runtime visibility, teams struggle to answer simple operational questions:

- Which workflows are degraded right now?
- Where are failures occurring in the flow?
- Are retries and queues behaving as expected?

## How Jido addresses this

The workbench uses two complementary observability surfaces:

- Phoenix telemetry metrics via `AgentJidoWeb.Telemetry`
- Runtime-focused pages from `jido_live_dashboard` mounted in LiveDashboard

That combination gives teams both application-level and agent-runtime-level views for operations and incident response.

## Proof: see it work

The router mounts LiveDashboard with Jido runtime pages enabled:

```elixir
live_dashboard("/dashboard",
  metrics: AgentJidoWeb.Telemetry,
  additional_pages: JidoLiveDashboard.pages(),
  on_mount: @admin_on_mount
)
```

**Result:**

```
/dev/dashboard includes Phoenix metrics and Jido runtime/trace pages.
```

For a runnable operational example, open [Demand Tracker Agent](/examples/demand-tracker-agent), then inspect behavior in dashboard traces and metrics while signals are processed.

## How this differs

Many prototype-first approaches treat observability as something you add after workflow logic is complete. That delays operational feedback until late in the lifecycle.

Jido expects operating concerns early: telemetry dimensions, runtime introspection, and debugging workflows are part of the design conversation from the first production candidate.

## Learn more

- **Ecosystem:** [Jido Live Dashboard](/ecosystem/jido_live_dashboard) and [Jido core runtime](/ecosystem/jido)
- **Training:** [Production Readiness: Supervision, Telemetry, and Failure Modes](/training/production-readiness)
- **Docs:** [Production Readiness Checklist](/docs/production-readiness-checklist) and [Incident Playbooks](/docs/incident-playbooks)
- **Context:** [All feature pillars](/features)

## Get Building

Ready to operationalize your workflow? [Get Building](/getting-started), then run your first readiness pass with the [production checklist](/docs/production-readiness-checklist).
