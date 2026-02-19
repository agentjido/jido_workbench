%{
  title: "CSV Import Validator Agent",
  description: "Interactive Jido example for csv import validator agent focusing on action contracts and validation. Includes a dedicated LiveView companion and source-first learning flow.",
  tags: ["top20", "rank-13", "core", "l2", "core-mechanics"],
  category: :core,
  emoji: "CORE",
  source_files: [
    "lib/agent_jido/demos/csv_import_validator/csv_import_validator_agent.ex",
    "lib/agent_jido/demos/csv_import_validator/actions/execute_action.ex",
    "lib/agent_jido/demos/csv_import_validator/actions/reset_action.ex",
    "lib/agent_jido_web/examples/csv_import_validator_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.CsvImportValidatorAgentLive",
  difficulty: :beginner,
  sort_order: 46
}
---

## What you'll learn

- Action contracts and validation
- Agent state/schema fundamentals
- Signals and routing
- How to wire a dedicated LiveView demo: `AgentJidoWeb.Examples.CsvImportValidatorAgentLive`

## How it works

This example is part of the top-20 rollout and is scoped to one clear learning outcome: **Action contracts and validation**.

### Agent Boundary

- Planned agent module: `AgentJido.Demos.CsvImportValidatorAgent`
- Capability focus: Jido.Agent schema
- Capability focus: Jido.Action validation
- Capability focus: cmd/2 transitions

### LiveView Boundary

- Demo module: `AgentJidoWeb.Examples.CsvImportValidatorAgentLive`
- Demo source target: `lib/agent_jido_web/examples/csv_import_validator_agent_live.ex`
- Route: `/examples/csv-import-validator-agent`

### Implementation Checklist

1. Implement the agent and actions listed in `source_files`.
2. Implement LiveView events and deterministic state rendering.
3. Verify explanation, source, and demo tabs all load correctly.
4. Add tests for route rendering and one core demo interaction.

## Prerequisites

- `training/agent-fundamentals`
- `training/actions-validation`

## Story Link

Build this example in `ST-EX-013` from `specs/stories/07_examples_top20_liveview.md`.
