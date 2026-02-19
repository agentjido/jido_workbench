%{
  title: "Multi-Agent Coordination",
  category: :features,
  description: "Orchestrate fleets of agents with supervision trees, signal routing, and distributed coordination.",
  doc_type: :explanation,
  audience: :intermediate,
  draft: false,
  order: 20
}
---
Jido models multi-agent behavior as explicit coordination contracts: Signals for communication, Actions for capability boundaries, and Directives for runtime side effects.

## The problem

Coordination usually becomes fragile when it is encoded implicitly in prompts, callback chains, or shared mutable state. Teams can ship an initial workflow quickly, but debugging cross-agent behavior gets expensive as more agents are added.

Typical failure modes include:

- Hidden coupling between producer and consumer behavior
- Unclear ownership of side effects and retries
- Coordination logic that is hard to test without full end-to-end environments

## How Jido addresses this

Jido coordination is structural, not implicit:

- Signal routes map named events to Action modules.
- Actions define typed input contracts and deterministic state transitions.
- Directives describe side effects after state updates, so behavior remains inspectable.

This keeps coordination logic readable in code reviews and testable in small units before you run a full distributed workflow.

## Proof: see it work

The demand tracker demo exposes coordination contracts directly in code and tests.

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

**Result:**

```
Coordination is explicit: route table + typed action + emitted domain signal.
```

Run the end-to-end version in [Demand Tracker Agent](/examples/demand-tracker-agent).

## How this differs

In prototype-first stacks, multi-agent behavior is often represented as prompt choreography plus framework callbacks. That can work for quick evaluation, but it can be difficult to reason about ownership and failure boundaries.

Jido favors explicit contracts that can be asserted in tests. You can verify route mappings and emitted directives with the same primitives used in production workflows.

## Learn more

- **Ecosystem:** [Jido Signal](/ecosystem/jido_signal) and [Jido Action](/ecosystem/jido_action)
- **Training:** [Signals, Routing, and Agent Communication](/training/signals-routing)
- **Training:** [Directives, Scheduling, and Time-Based Behavior](/training/directives-scheduling)
- **Docs:** [Architecture](/docs/reference/architecture) and [Reference](/docs/reference)
- **Context:** [All feature pillars](/features)

## Get Building

Ready to design explicit coordination paths? [Get Building](/getting-started), then validate your flow against [Signals and Routing training](/training/signals-routing).
