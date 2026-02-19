%{
  title: "Meeting Prep Briefing Console",
  description: "Interactive Jido example for meeting prep briefing console focusing on ai/tool-use integration. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-7", "ai", "l1", "liveview-product"],
  category: :ai,
  emoji: "AI",
  source_files: [
    "lib/agent_jido/demos/meeting_prep_briefing_console/meeting_prep_briefing_console_agent.ex",
    "lib/agent_jido/demos/meeting_prep_briefing_console/actions/execute_action.ex",
    "lib/agent_jido/demos/meeting_prep_briefing_console/actions/reset_action.ex",
    "lib/agent_jido_web/examples/meeting_prep_briefing_console_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.MeetingPrepBriefingConsoleLive",
  difficulty: :beginner,
  sort_order: 37
}
---

## What you'll learn

- AI/tool-use integration
- Action contracts and validation
- LiveView interaction patterns
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.MeetingPrepBriefingConsoleLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **AI/tool-use integration**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.MeetingPrepBriefingConsoleAgent`
- Capability focus: Phoenix LiveView
- Capability focus: AgentServer state polling
- Capability focus: UI event -> command mapping

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.MeetingPrepBriefingConsoleLive`
- Demo source target: `lib/agent_jido_web/examples/meeting_prep_briefing_console_live.ex`
- Route: `/examples/meeting-prep-briefing-console`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `training/liveview-integration`

## Story Link

Build this example in `ST-EX-007` from `specs/stories/07_examples_top20_liveview.md`.
