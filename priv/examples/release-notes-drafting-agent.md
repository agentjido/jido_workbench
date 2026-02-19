%{
  title: "Release Notes Drafting Agent",
  description: "Interactive Jido example for release notes drafting agent focusing on telemetry/observability. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-18", "ai", "l2", "ai-tool-use"],
  category: :ai,
  emoji: "AI",
  source_files: [
    "lib/agent_jido/demos/release_notes_drafting/release_notes_drafting_agent.ex",
    "lib/agent_jido/demos/release_notes_drafting/actions/execute_action.ex",
    "lib/agent_jido/demos/release_notes_drafting/actions/reset_action.ex",
    "lib/agent_jido_web/examples/release_notes_drafting_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.ReleaseNotesDraftingAgentLive",
  difficulty: :beginner,
  sort_order: 57
}
---

## What you'll learn

- Telemetry/observability
- AgentServer runtime lifecycle
- Security/governance/incident readiness
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.ReleaseNotesDraftingAgentLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Telemetry/observability**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.ReleaseNotesDraftingAgent`
- Capability focus: Jido.AI ReActAgent
- Capability focus: tool schemas
- Capability focus: structured tool results

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.ReleaseNotesDraftingAgentLive`
- Demo source target: `lib/agent_jido_web/examples/release_notes_drafting_agent_live.ex`
- Route: `/examples/release-notes-drafting-agent`

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

Build this example in `ST-EX-018` from `specs/stories/07_examples_top20_liveview.md`.
