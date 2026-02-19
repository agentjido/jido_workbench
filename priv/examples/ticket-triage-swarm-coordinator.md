%{
  title: "Ticket Triage Swarm Coordinator",
  description: "Interactive Jido example for ticket triage swarm coordinator focusing on directives (emit/schedule). Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-9", "core", "l1", "coordination"],
  category: :core,
  emoji: "CORE",
  source_files: [
    "lib/agent_jido/demos/ticket_triage_swarm_coordinator/ticket_triage_swarm_coordinator_agent.ex",
    "lib/agent_jido/demos/ticket_triage_swarm_coordinator/actions/execute_action.ex",
    "lib/agent_jido/demos/ticket_triage_swarm_coordinator/actions/reset_action.ex",
    "lib/agent_jido_web/examples/ticket_triage_swarm_coordinator_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.TicketTriageSwarmCoordinatorLive",
  difficulty: :beginner,
  sort_order: 40
}
---

## What you'll learn

- Directives (emit/schedule)
- Signals and routing
- AgentServer runtime lifecycle
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.TicketTriageSwarmCoordinatorLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Directives (emit/schedule)**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.TicketTriageSwarmCoordinatorAgent`
- Capability focus: signal_routes/1
- Capability focus: Directive.emit
- Capability focus: Directive.schedule
- Capability focus: cross-agent handoff

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.TicketTriageSwarmCoordinatorLive`
- Demo source target: `lib/agent_jido_web/examples/ticket_triage_swarm_coordinator_live.ex`
- Route: `/examples/ticket-triage-swarm-coordinator`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`

## Story Link

Build this example in `ST-EX-009` from `specs/stories/07_examples_top20_liveview.md`.
