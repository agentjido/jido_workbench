%{
  title: "Executive Brief",
  category: :features,
  description: "A concise overview of Jido for technical decision-makers evaluating agent infrastructure.",
  doc_type: :explanation,
  audience: :beginner,
  draft: false,
  order: 70
}
---
Jido is a runtime for reliable, multi-agent systems. It gives engineering organizations a path from initial workflow pilots to production operation with explicit coordination and BEAM-native failure boundaries.

## The problem

Technical leaders evaluating agent infrastructure usually need to answer four questions quickly:

- Can the architecture isolate failures and recover predictably?
- Can teams adopt incrementally without a platform rewrite?
- Are coordination and side effects explicit enough for code review and testing?
- Is there an operational surface for telemetry and incident response?

Many options address one or two of these concerns. Fewer provide a coherent runtime model across all four.

## How Jido addresses this

Jido combines runtime primitives and operational tooling:

- **Runtime model:** Agents, Actions, Signals, and Directives form explicit execution contracts.
- **Reliability model:** `Jido.AgentServer` runs under OTP supervision to constrain blast radius and recovery behavior.
- **Adoption model:** Teams can start with one workflow and scale out package usage over time.
- **Operations model:** Phoenix telemetry and Jido dashboard pages support production visibility.

This lets teams evaluate one architecture posture from prototype to production instead of switching models midstream.

## Proof: see it work

The workbench runs a supervised orchestration Agent and exposes runtime state through the agent server.

```elixir
{:ok, _pid} =
  Jido.AgentServer.start_link(
    id: AgentJido.ContentOps.OrchestratorServer,
    agent: AgentJido.ContentOps.OrchestratorAgent,
    jido: AgentJido.Jido,
    name: AgentJido.ContentOps.OrchestratorServer
  )

{:ok, server_state} = Jido.AgentServer.state(AgentJido.ContentOps.OrchestratorServer)
is_map(server_state.agent.state)
```

**Result:**

```
true
```

A core workflow runs in a supervised runtime process with inspectable state, which is the same operational posture used across broader adoption.

## How this differs

Framework-first stacks can accelerate exploratory implementation, but they often leave lifecycle and operations concerns to additional app-layer conventions.

Jido is a fit when your decision criteria include reliability boundaries, operability, and long-term maintainability. The tradeoff is more explicit structure up front in exchange for clearer behavior under production load.

## Learn more

- **Ecosystem:** [Package matrix](/ecosystem/package-matrix) and [Jido core runtime](/ecosystem/jido)
- **Training:** [Production Readiness: Supervision, Telemetry, and Failure Modes](/training/production-readiness)
- **Docs:** [Architecture](/docs/architecture), [Reference](/docs/reference), and [Security and Governance](/docs/security-and-governance)
- **Context:** [Comparison details](/features/jido-vs-framework-first-stacks) and [all feature pillars](/features)

## Get Building

Ready for a technical evaluation sprint? [Get Building](/getting-started), then align package scope with the [ecosystem matrix](/ecosystem/package-matrix).
