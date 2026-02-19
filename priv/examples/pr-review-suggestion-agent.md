%{
  title: "PR Review Suggestion Agent",
  description: "Interactive Jido example for pr review suggestion agent focusing on ai/tool-use integration. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-11", "ai", "l1", "ai-tool-use"],
  category: :ai,
  emoji: "AI",
  source_files: [
    "lib/agent_jido/demos/pr_review_suggestion/pr_review_suggestion_agent.ex",
    "lib/agent_jido/demos/pr_review_suggestion/actions/execute_action.ex",
    "lib/agent_jido/demos/pr_review_suggestion/actions/reset_action.ex",
    "lib/agent_jido_web/examples/pr_review_suggestion_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.PrReviewSuggestionAgentLive",
  difficulty: :beginner,
  sort_order: 42
}
---

## What you'll learn

- AI/tool-use integration
- Action contracts and validation
- LiveView interaction patterns
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.PrReviewSuggestionAgentLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **AI/tool-use integration**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.PrReviewSuggestionAgent`
- Capability focus: Jido.AI ReActAgent
- Capability focus: tool schemas
- Capability focus: structured tool results

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.PrReviewSuggestionAgentLive`
- Demo source target: `lib/agent_jido_web/examples/pr_review_suggestion_agent_live.ex`
- Route: `/examples/pr-review-suggestion-agent`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `build/tool-use`

## Story Link

Build this example in `ST-EX-011` from `specs/stories/07_examples_top20_liveview.md`.
