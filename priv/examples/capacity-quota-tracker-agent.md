%{
  title: "Capacity Quota Tracker Agent",
  description: "Interactive Jido example for capacity quota tracker agent focusing on action contracts and validation. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-3", "core", "l1", "core-mechanics"],
  category: :core,
  emoji: "CORE",
  source_files: [
    "lib/agent_jido/demos/capacity_quota_tracker/capacity_quota_tracker_agent.ex",
    "lib/agent_jido/demos/capacity_quota_tracker/actions/execute_action.ex",
    "lib/agent_jido/demos/capacity_quota_tracker/actions/reset_action.ex",
    "lib/agent_jido_web/examples/capacity_quota_tracker_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.CapacityQuotaTrackerAgentLive",
  difficulty: :beginner,
  sort_order: 23
}
---

## What you'll learn

- Action contracts and validation
- Agent state/schema fundamentals
- Signals and routing
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.CapacityQuotaTrackerAgentLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Action contracts and validation**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.CapacityQuotaTrackerAgent`
- Capability focus: Jido.Agent schema
- Capability focus: Jido.Action validation
- Capability focus: cmd/2 transitions

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.CapacityQuotaTrackerAgentLive`
- Demo source target: `lib/agent_jido_web/examples/capacity_quota_tracker_agent_live.ex`
- Route: `/examples/capacity-quota-tracker-agent`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`

## Story Link

Build this example in `ST-EX-003` from `specs/stories/07_examples_top20_liveview.md`.
