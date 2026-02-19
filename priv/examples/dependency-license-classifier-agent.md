%{
  title: "Dependency License Classifier Agent",
  description: "Interactive Jido example for dependency license classifier agent focusing on agent state/schema fundamentals. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-16", "core", "l2", "core-mechanics"],
  category: :core,
  emoji: "CORE",
  source_files: [
    "lib/agent_jido/demos/dependency_license_classifier/dependency_license_classifier_agent.ex",
    "lib/agent_jido/demos/dependency_license_classifier/actions/execute_action.ex",
    "lib/agent_jido/demos/dependency_license_classifier/actions/reset_action.ex",
    "lib/agent_jido_web/examples/dependency_license_classifier_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.DependencyLicenseClassifierAgentLive",
  difficulty: :beginner,
  sort_order: 50
}
---

## What you'll learn

- Agent state/schema fundamentals
- Action contracts and validation
- AgentServer runtime lifecycle
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.DependencyLicenseClassifierAgentLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Agent state/schema fundamentals**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.DependencyLicenseClassifierAgent`
- Capability focus: Jido.Agent schema
- Capability focus: Jido.Action validation
- Capability focus: cmd/2 transitions

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.DependencyLicenseClassifierAgentLive`
- Demo source target: `lib/agent_jido_web/examples/dependency_license_classifier_agent_live.ex`
- Route: `/examples/dependency-license-classifier-agent`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `training/actions-validation`

## Story Link

Build this example in `ST-EX-016` from `specs/stories/07_examples_top20_liveview.md`.
