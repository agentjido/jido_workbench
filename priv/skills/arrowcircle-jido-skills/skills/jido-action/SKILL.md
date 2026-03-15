---
name: jido-action
description: Builder-oriented guidance for the upstream `jido_action` package. Use when Codex needs to scaffold or review `Jido.Action` modules, validate action inputs and outputs, compose actions into agent workflows, or turn action docs into runnable Elixir examples.
---

# Jido Action

`jido_action` is the upstream Hex package name.

## Start Here

Use this skill when the task is centered on `Jido.Action` as the unit of executable work.

Good triggers:
- "Create a new `Jido.Action` for this side effect."
- "Review this action for schema validation or output shape."
- "Turn the action docs into a runnable example."
- "Figure out whether this logic belongs in one action or in agent orchestration."

Read [references/builder-notes.md](references/builder-notes.md) before editing when the task involves action contracts, composition, retries, or error boundaries.

## Primary Workflows

### Scaffold an action

- Start from the action's boundary: one job, one clear input contract, one clear result shape.
- Define parameters and validation up front instead of burying checks in `run/2`.
- Keep side effects explicit so callers can reason about retries and compensation.

### Extend or refactor an action

- Split oversized actions when they hide orchestration, branching, or unrelated IO.
- Preserve stable inputs and outputs when improving internals.
- Prefer composition through other Jido layers over building a giant action with internal state machines.

### Turn docs into runnable examples

- Use realistic params and output values.
- Show how an action is invoked in isolation before showing how an agent or directive uses it.
- Include one error path if the action handles validation or external failures.

### Review boundaries

- Keep low-level units of work in `Jido.Action`.
- Keep routing, branching, and multi-step control flow in `jido` or `jido-behaviortree`.
- Keep signal schemas in `jido-signal`.

## Build Checklist

- Define the input schema first.
- Decide whether the action is pure, IO-bound, or adapter-like.
- Return consistent success and failure shapes.
- Add focused tests for validation, happy path, and recoverable failure.

## Boundaries

- Do not use one action to represent a whole agent workflow.
- Do not hide long-lived state inside the action module.
- Do not mix unrelated side effects just because they happen in one feature.
