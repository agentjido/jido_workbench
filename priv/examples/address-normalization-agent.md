%{
  title: "Address Normalization Agent",
  description: "Interactive Jido example for address normalization agent focusing on action contracts and validation. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-1", "core", "l1", "core-mechanics"],
  category: :core,
  emoji: "CORE",
  source_files: [
    "lib/agent_jido/demos/address_normalization/address_normalization_agent.ex",
    "lib/agent_jido/demos/address_normalization/actions/execute_action.ex",
    "lib/agent_jido/demos/address_normalization/actions/reset_action.ex",
    "lib/agent_jido_web/examples/address_normalization_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.AddressNormalizationAgentLive",
  difficulty: :beginner,
  sort_order: 21
}
---

## What you'll learn

- Action contracts and validation
- Agent state/schema fundamentals
- Signals and routing
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.AddressNormalizationAgentLive`

## How it works

This example focuses on one learning outcome: **Action contracts and validation**.

The interactive demo runs two deterministic payloads:

1. A valid US-style address payload that normalizes into a canonical string.
2. An invalid payload (missing `postal_code`) that is rejected by the action contract.

### Agent Boundary

- Agent module: `AgentJido.Demos.AddressNormalizationAgent`
- Execute action: `AgentJido.Demos.AddressNormalization.ExecuteAction`
- Reset action: `AgentJido.Demos.AddressNormalization.ResetAction`
- Agent API: `AddressNormalizationAgent.cmd/2`

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.AddressNormalizationAgentLive`
- Demo source target: `lib/agent_jido_web/examples/address_normalization_agent_live.ex`
- Route: `/examples/address-normalization-agent`

### Demo flow

1. Click **Run Valid Payload** to normalize a deterministic address sample.
2. Click **Run Invalid Payload** to trigger action validation rejection.
3. Click **Reset** to clear the demo state.

## Prerequisites

- `training/agent-fundamentals`

## Story Link

Build this example in `ST-EX-001` from `specs/stories/07_examples_top20_liveview.md`.
