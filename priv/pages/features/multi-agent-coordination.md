%{
  title: "Multi-Agent Coordination",
  category: :features,
  description: "Coordinate agent workflows with explicit Signals, typed Actions, and strategy-driven orchestration.",
  doc_type: :explanation,
  audience: :intermediate,
  draft: false,
  order: 20
}
---
Jido models multi-agent coordination as explicit runtime contracts. Signals define message boundaries, Actions define capability boundaries, and Directives define effect boundaries.

## At a glance

| Item | Summary |
|---|---|
| Best for | AI product engineers, staff architects, and teams moving beyond single-agent flows |
| Core packages | [jido_signal](/ecosystem/jido_signal), [jido_action](/ecosystem/jido_action), [jido](/ecosystem/jido) |
| Strategy add-ons | [jido_behaviortree](/ecosystem/jido_behaviortree), [jido_runic](/ecosystem/jido_runic) |
| Package status | `jido_signal` (Beta), `jido_action` (Beta), strategy add-ons (Experimental) |
| First proof path | [Demand Tracker Agent](/examples/demand-tracker-agent) -> [Signals routing training](/training/signals-routing) |

## Why coordination gets fragile

Coordination fails when behavior is encoded implicitly:

- Producer and consumer logic depend on undocumented callback order.
- Side-effect ownership is unclear across agent boundaries.
- Teams cannot test route-to-action behavior without running full environments.

Jido addresses this with explicit route tables, typed Actions, and inspectable Directives.

## Capability map

| Capability | Runtime mechanism | Package proof | Status |
|---|---|---|---|
| Event envelope consistency | CloudEvents-compatible Signal schema | [jido_signal](/ecosystem/jido_signal) | Beta |
| Route-level coordination | Signal route tables map event type -> Action module | [jido_signal](/ecosystem/jido_signal) | Beta |
| Typed capability execution | Action schema validation + execution controls | [jido_action](/ecosystem/jido_action) | Beta |
| Explicit side effects | Directives emitted from `cmd/2` instead of ad-hoc calls | [jido](/ecosystem/jido) | Beta |
| Strategy modularity | Behavior tree and DAG workflow strategy packages | [jido_behaviortree](/ecosystem/jido_behaviortree), [jido_runic](/ecosystem/jido_runic) | Experimental |

## Proof: verify route contracts and emitted directives

```elixir
alias AgentJido.Demos.DemandTrackerAgent
alias AgentJido.Demos.Demand.BoostAction
alias Jido.Agent.Directive.Emit

routes = DemandTrackerAgent.signal_routes(%{})
{"listing.demand.boost", BoostAction} in routes
#=> true

{_agent, directives} = DemandTrackerAgent.cmd(DemandTrackerAgent.new(), BoostAction)
Enum.any?(directives, &match?(%Emit{}, &1))
#=> true
```

Expected result:

```
true
```

This proves a concrete route mapping and an explicit emitted side effect using the same primitives you use in production.

## Tradeoffs and non-goals

- Explicit route and action design is slower up front than prompt-only choreography.
- Experimental strategy packages should be used with bounded pilots.
- Coordination clarity does not remove the need for domain-level retry and idempotency policies.

## What to explore next

- **Reliability boundary design:** [Reliability by architecture](/features/reliability-by-architecture)
- **Operational posture:** [Operations and observability](/features/operations-observability)
- **Training paths:** [Signals routing](/training/signals-routing), [Directives scheduling](/training/directives-scheduling)
- **Reference docs:** [Architecture](/docs/reference/architecture), [Guides](/docs/guides)

## Get Building

Start with [Demand Tracker Agent](/examples/demand-tracker-agent), then validate your first route table with [Signals routing training](/training/signals-routing).
