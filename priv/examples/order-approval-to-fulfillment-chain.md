%{
  title: "Order Approval to Fulfillment Chain",
  description: "Interactive Jido example for order approval to fulfillment chain focusing on signals and routing. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-8", "core", "l1", "coordination"],
  category: :core,
  emoji: "CORE",
  source_files: [
    "lib/agent_jido/demos/order_approval_to_fulfillment_chain/order_approval_to_fulfillment_chain_agent.ex",
    "lib/agent_jido/demos/order_approval_to_fulfillment_chain/actions/execute_action.ex",
    "lib/agent_jido/demos/order_approval_to_fulfillment_chain/actions/reset_action.ex",
    "lib/agent_jido_web/examples/order_approval_to_fulfillment_chain_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.OrderApprovalToFulfillmentChainLive",
  difficulty: :beginner,
  sort_order: 38
}
---

## What you'll learn

- Signals and routing
- Directives (emit/schedule)
- Multi-agent orchestration
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.OrderApprovalToFulfillmentChainLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Signals and routing**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.OrderApprovalToFulfillmentChainAgent`
- Capability focus: signal_routes/1
- Capability focus: Directive.emit
- Capability focus: Directive.schedule
- Capability focus: cross-agent handoff

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.OrderApprovalToFulfillmentChainLive`
- Demo source target: `lib/agent_jido_web/examples/order_approval_to_fulfillment_chain_live.ex`
- Route: `/examples/order-approval-to-fulfillment-chain`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`

## Story Link

Build this example in `ST-EX-008` from `specs/stories/07_examples_top20_liveview.md`.
