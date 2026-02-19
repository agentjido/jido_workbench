%{
  title: "Incident Timeline Narrator Agent",
  description: "Interactive Jido example for incident timeline narrator agent focusing on telemetry/observability. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-17", "ai", "l2", "ai-tool-use"],
  category: :ai,
  emoji: "AI",
  source_files: [
    "lib/agent_jido/demos/incident_timeline_narrator/incident_timeline_narrator_agent.ex",
    "lib/agent_jido/demos/incident_timeline_narrator/actions/execute_action.ex",
    "lib/agent_jido/demos/incident_timeline_narrator/actions/reset_action.ex",
    "lib/agent_jido_web/examples/incident_timeline_narrator_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.IncidentTimelineNarratorAgentLive",
  difficulty: :beginner,
  sort_order: 56
}
---

## What you'll learn

- Telemetry/observability
- AgentServer runtime lifecycle
- Security/governance/incident readiness
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.IncidentTimelineNarratorAgentLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Telemetry/observability**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.IncidentTimelineNarratorAgent`
- Capability focus: Jido.AI ReActAgent
- Capability focus: tool schemas
- Capability focus: structured tool results

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.IncidentTimelineNarratorAgentLive`
- Demo source target: `lib/agent_jido_web/examples/incident_timeline_narrator_agent_live.ex`
- Route: `/examples/incident-timeline-narrator-agent`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `training/actions-validation`
- `build/tool-use`

## Story Link

Build this example in `ST-EX-017` from `specs/stories/07_examples_top20_liveview.md`.
