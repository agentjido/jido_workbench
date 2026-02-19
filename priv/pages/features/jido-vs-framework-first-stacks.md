%{
  title: "Jido vs Framework-First Stacks",
  category: :features,
  description: "How Jido compares to LangChain, CrewAI, AutoGen, and other agent frameworks.",
  doc_type: :explanation,
  audience: :beginner,
  draft: false,
  order: 60
}
---
This comparison is about operating model, not brand ranking. If your team needs long-lived, observable, and recoverable agent workflows, runtime architecture matters as much as API ergonomics.

## The problem

Many evaluations prioritize how quickly a prototype can be assembled. That is useful, but production teams also need answers to operational questions:

- Where do failures get isolated?
- How do workflows recover after process exits?
- Can coordination behavior be asserted in tests without full end-to-end environments?

If those answers remain implicit, teams often pay the cost later during incident response and maintenance.

## How Jido addresses this

Jido is runtime-first:

- Agents expose explicit signal routes and typed Actions.
- State transitions happen in deterministic `cmd/2` paths.
- Side effects are represented as Directives and managed under OTP supervision.

Framework-first stacks can be a good fit for rapid exploration. Jido is designed for teams that need production operation characteristics to be part of the architecture from the first real workload.

## Proof: see it work

Coordination and state changes are explicit in code and can be asserted directly.

```elixir
alias AgentJido.Demos.CounterAgent
alias AgentJido.Demos.Counter.IncrementAction

routes = CounterAgent.signal_routes(%{})
{"counter.increment", IncrementAction} in routes
#=> true

{agent, _directives} = CounterAgent.cmd(CounterAgent.new(), {IncrementAction, %{by: 3}})
agent.state.count
```

**Result:**

```
3
```

The same primitives used in production execution can be validated in focused tests.

## How this differs

LangChain, CrewAI, AutoGen, and similar stacks can be excellent for quick iteration and prototype velocity. That fit is real when the main objective is short-cycle experimentation.

Jido is optimized for a different constraint set: explicit coordination contracts, supervised runtime boundaries, and operational clarity for multi-agent systems that must stay healthy after launch.

## Learn more

- **Ecosystem:** [Jido core runtime](/ecosystem/jido), [Jido Action](/ecosystem/jido_action), and [Jido Signal](/ecosystem/jido_signal)
- **Ecosystem:** [Package matrix](/ecosystem/package-matrix)
- **Training:** [Signals, Routing, and Agent Communication](/training/signals-routing)
- **Docs:** [Reference](/docs/reference) and [Architecture](/docs/architecture)
- **Context:** [All feature pillars](/features)

## Get Building

Ready to evaluate fit against your operating constraints? [Get Building](/getting-started), then map required packages in the [package matrix](/ecosystem/package-matrix).
