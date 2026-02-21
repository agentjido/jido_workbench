%{
  title: "Operations and observability",
  category: :features,
  description: "Operate agent workflows with telemetry, trace boundaries, and production readiness checks.",
  doc_type: :explanation,
  audience: :intermediate,
  draft: false,
  order: 30
}
---
Jido is designed for teams that need to run agents after launch. The runtime surfaces metrics, traces, and state boundaries that map to incident response and readiness workflows.

## At a glance

| Item | Summary |
|---|---|
| Best for | Platform/SRE teams, architects, and engineering leads responsible for uptime |
| Core packages | [jido](/ecosystem/jido), [jido_otel](/ecosystem/jido_otel) |
| Integration support | [jido_messaging](/ecosystem/jido_messaging) for channel-level workflows |
| Package status | `jido` (Beta), `jido_otel` (Experimental), `jido_messaging` (Experimental) |
| First proof path | [Telemetry SLO budget sentinel](/examples/telemetry-slo-budget-sentinel) -> [Production readiness checklist](/docs/operations/production-readiness-checklist) |

## What operations teams need from day one

Agent systems require more than logs:

- Runtime-level latency and queue pressure visibility.
- Trace boundaries across multi-step workflows.
- Repeatable runbooks for degraded or failed paths.

Jido supports this by making runtime behavior observable through telemetry and explicit execution boundaries.

## Capability map

| Capability | Runtime mechanism | Package proof | Status |
|---|---|---|---|
| Telemetry event emission | Runtime emits operational measurements and metadata | [jido](/ecosystem/jido) | Beta |
| Trace bridge integration | OpenTelemetry bridge for centralized tracing stacks | [jido_otel](/ecosystem/jido_otel) | Experimental |
| Channel workflow visibility | Messaging workflows expose telemetry + Signal events | [jido_messaging](/ecosystem/jido_messaging) | Experimental |
| Incident readiness flow | Checklist + playbooks map runtime symptoms to actions | [Production readiness checklist](/docs/operations/production-readiness-checklist), [Incident playbooks](/docs/operations/incident-playbooks) | Reference docs |

## Proof: dashboard wiring for runtime visibility

```elixir
live_dashboard("/dashboard",
  metrics: AgentJidoWeb.Telemetry,
  additional_pages: JidoLiveDashboard.pages(),
  on_mount: @admin_on_mount
)
```

Expected result:

```
/dev/dashboard exposes Phoenix metrics and Jido runtime pages.
```

Pair this with [Demand Tracker Agent](/examples/demand-tracker-agent) to inspect runtime behavior while signals are processed.

## Tradeoffs and non-goals

- Observability quality depends on instrumentation discipline and alert design.
- Experimental observability/integration packages should be validated in bounded environments first.
- Jido does not remove the need for team-specific SLO design and incident ownership.

## What to explore next

- **Failure boundaries:** [Reliability by architecture](/features/reliability-by-architecture)
- **Coordination traces:** [Multi-agent coordination](/features/multi-agent-coordination)
- **Training:** [Production readiness](/training/production-readiness)
- **Reference docs:** [Production readiness checklist](/docs/operations/production-readiness-checklist), [Incident playbooks](/docs/operations/incident-playbooks), [Security and governance](/docs/operations/security-and-governance)

## Get Building

Run [Telemetry SLO budget sentinel](/examples/telemetry-slo-budget-sentinel), then complete one pass of the [production readiness checklist](/docs/operations/production-readiness-checklist).
