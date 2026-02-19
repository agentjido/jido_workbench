%{
  title: "Telemetry SLO Budget Sentinel",
  description: "Interactive Jido example for telemetry slo budget sentinel focusing on telemetry/observability. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-12", "production", "l1", "ops-governance"],
  category: :production,
  emoji: "PRODUCTION",
  source_files: [
    "lib/agent_jido/demos/telemetry_slo_budget_sentinel/telemetry_slo_budget_sentinel_agent.ex",
    "lib/agent_jido/demos/telemetry_slo_budget_sentinel/actions/execute_action.ex",
    "lib/agent_jido/demos/telemetry_slo_budget_sentinel/actions/reset_action.ex",
    "lib/agent_jido_web/examples/telemetry_slo_budget_sentinel_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.TelemetrySloBudgetSentinelLive",
  difficulty: :beginner,
  sort_order: 44
}
---

## What you'll learn

- Telemetry/observability
- AgentServer runtime lifecycle
- Security/governance/incident readiness
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.TelemetrySloBudgetSentinelLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Telemetry/observability**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.TelemetrySloBudgetSentinelAgent`
- Capability focus: telemetry events
- Capability focus: supervision policies
- Capability focus: guardrail checks

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.TelemetrySloBudgetSentinelLive`
- Demo source target: `lib/agent_jido_web/examples/telemetry_slo_budget_sentinel_live.ex`
- Route: `/examples/telemetry-slo-budget-sentinel`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `docs/production-readiness-checklist`

## Story Link

Build this example in `ST-EX-012` from `specs/stories/07_examples_top20_liveview.md`.
