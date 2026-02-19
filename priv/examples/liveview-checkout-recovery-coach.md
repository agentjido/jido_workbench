%{
  title: "LiveView Checkout Recovery Coach",
  description: "Interactive Jido example for liveview checkout recovery coach focusing on liveview interaction patterns. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-6", "ai", "l1", "liveview-product"],
  category: :ai,
  emoji: "AI",
  source_files: [
    "lib/agent_jido/demos/liveview_checkout_recovery_coach/liveview_checkout_recovery_coach_agent.ex",
    "lib/agent_jido/demos/liveview_checkout_recovery_coach/actions/execute_action.ex",
    "lib/agent_jido/demos/liveview_checkout_recovery_coach/actions/reset_action.ex",
    "lib/agent_jido_web/examples/liveview_checkout_recovery_coach_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.LiveviewCheckoutRecoveryCoachLive",
  difficulty: :beginner,
  sort_order: 36
}
---

## What you'll learn

- LiveView interaction patterns
- AI/tool-use integration
- Signals and routing
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.LiveviewCheckoutRecoveryCoachLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **LiveView interaction patterns**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.LiveviewCheckoutRecoveryCoachAgent`
- Capability focus: Phoenix LiveView
- Capability focus: AgentServer state polling
- Capability focus: UI event -> command mapping

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.LiveviewCheckoutRecoveryCoachLive`
- Demo source target: `lib/agent_jido_web/examples/liveview_checkout_recovery_coach_live.ex`
- Route: `/examples/liveview-checkout-recovery-coach`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `training/liveview-integration`

## Story Link

Build this example in `ST-EX-006` from `specs/stories/07_examples_top20_liveview.md`.
