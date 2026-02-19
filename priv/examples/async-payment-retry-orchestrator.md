%{
  title: "Async Payment Retry Orchestrator",
  description: "Interactive Jido example for async payment retry orchestrator focusing on signals and routing. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-19", "core", "l2", "coordination"],
  category: :core,
  emoji: "CORE",
  source_files: [
    "lib/agent_jido/demos/async_payment_retry_orchestrator/async_payment_retry_orchestrator_agent.ex",
    "lib/agent_jido/demos/async_payment_retry_orchestrator/actions/execute_action.ex",
    "lib/agent_jido/demos/async_payment_retry_orchestrator/actions/reset_action.ex",
    "lib/agent_jido_web/examples/async_payment_retry_orchestrator_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.AsyncPaymentRetryOrchestratorLive",
  difficulty: :beginner,
  sort_order: 58
}
---

## What you'll learn

- Signals and routing
- Directives (emit/schedule)
- Multi-agent orchestration
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.AsyncPaymentRetryOrchestratorLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Signals and routing**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.AsyncPaymentRetryOrchestratorAgent`
- Capability focus: signal_routes/1
- Capability focus: Directive.emit
- Capability focus: Directive.schedule
- Capability focus: cross-agent handoff

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.AsyncPaymentRetryOrchestratorLive`
- Demo source target: `lib/agent_jido_web/examples/async_payment_retry_orchestrator_live.ex`
- Route: `/examples/async-payment-retry-orchestrator`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `training/actions-validation`

## Story Link

Build this example in `ST-EX-019` from `specs/stories/07_examples_top20_liveview.md`.
