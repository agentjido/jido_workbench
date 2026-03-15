---
name: jido
description: Builder-oriented guidance for the upstream `jido` package. Use when Codex needs to design or review Jido agents, directives, action pipelines, runtime loops, or example applications that compose `jido_action`, `jido_signal`, memory, and AI-facing packages into working Elixir systems.
---

# Jido

`jido` is the upstream Hex package name.

## Start Here

Use this skill for the core agent runtime and orchestration layer.

Good triggers:
- "Design a Jido agent for this workflow."
- "Refactor this runtime loop into actions, directives, and signals."
- "Turn the Jido docs into a runnable agent example."
- "Review whether a feature belongs in core Jido or a package-specific extension."

Read [references/builder-notes.md](references/builder-notes.md) before coding when the task spans multiple Jido concepts or packages.

## Primary Workflows

### Design an agent runtime

- Start with the agent boundary: state, directives, allowed actions, emitted signals, and external dependencies.
- Keep planning and execution explicit. Do not smuggle hidden orchestration into one action or one callback.
- Prefer small, composable workflows that can be tested without a full application shell.

### Compose ecosystem packages

- Reach for `jido-action` when the job is an executable unit of work.
- Reach for `jido-signal` when the job is event shape and dispatch.
- Reach for `jido-memory`, `req-llm`, `llm-db`, or `ash-jido` only when the feature truly crosses into those domains.

### Turn docs into runnable examples

- Build a thin end-to-end example: agent definition, one or two actions, one signal path, and one observable result.
- Prefer examples that demonstrate runtime decisions or directives over static data transforms.
- Keep examples executable in tests or `iex`, not locked to a large demo app.

### Review boundaries

- Keep core runtime coordination in `jido`.
- Push provider, catalog, browser, memory, and Ash-specific details into their package skills.
- Narrow proposals that require undocumented runtime hooks.

## Build Checklist

- Define the agent state and lifecycle before writing callbacks.
- List the actions, directives, and signals that participate.
- Identify external integrations and keep them behind package boundaries.
- Add tests for state transitions, directive behavior, and failure recovery.

## Boundaries

- Do not use this skill for package-specific transport or provider code when another package already owns that boundary.
- Do not invent runtime primitives that the docs do not support.
- Do not let one agent absorb unrelated business workflows that should remain separate.
