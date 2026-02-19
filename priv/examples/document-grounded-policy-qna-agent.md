%{
  title: "Document-Grounded Policy QnA Agent",
  description: "Interactive Jido example for document-grounded policy qna agent focusing on action contracts and validation. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-10", "ai", "l1", "ai-tool-use"],
  category: :ai,
  emoji: "AI",
  source_files: [
    "lib/agent_jido/demos/document_grounded_policy_qna/document_grounded_policy_qna_agent.ex",
    "lib/agent_jido/demos/document_grounded_policy_qna/actions/execute_action.ex",
    "lib/agent_jido/demos/document_grounded_policy_qna/actions/reset_action.ex",
    "lib/agent_jido_web/examples/document_grounded_policy_qna_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.DocumentGroundedPolicyQnaAgentLive",
  difficulty: :beginner,
  sort_order: 41
}
---

## What you'll learn

- Action contracts and validation
- Agent state/schema fundamentals
- Signals and routing
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.DocumentGroundedPolicyQnaAgentLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Action contracts and validation**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.DocumentGroundedPolicyQnaAgent`
- Capability focus: Jido.AI ReActAgent
- Capability focus: tool schemas
- Capability focus: structured tool results

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.DocumentGroundedPolicyQnaAgentLive`
- Demo source target: `lib/agent_jido_web/examples/document_grounded_policy_qna_agent_live.ex`
- Route: `/examples/document-grounded-policy-qna-agent`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `build/tool-use`

## Story Link

Build this example in `ST-EX-010` from `specs/stories/07_examples_top20_liveview.md`.
