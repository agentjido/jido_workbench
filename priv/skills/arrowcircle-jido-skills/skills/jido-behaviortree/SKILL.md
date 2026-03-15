---
name: jido-behaviortree
description: Builder-oriented guidance for the upstream `jido_behaviortree` package. Use when Codex needs to model agent decision trees, selectors, sequences, or fallback paths in Jido, or when it needs to turn sparse behavior-tree docs into a concrete runnable example without inventing unsupported runtime features.
---

# Jido BehaviorTree

`jido_behaviortree` is the upstream Hex package name.

## Start Here

Use this skill when the task is about explicit branching, selectors, sequences, guards, or fallback execution inside a Jido workflow.

Good triggers:
- "Model this agent logic as a behavior tree."
- "Add fallback and guard behavior to a Jido agent."
- "Turn the behavior tree docs into a small working example."
- "Review whether this branching belongs in a tree or in regular Elixir control flow."

Read [references/builder-notes.md](references/builder-notes.md) before coding because the public docs are thinner here than for the core Jido packages.

## Primary Workflows

### Model a tree deliberately

- Start from the decision points: sequence, selector, guard, retry, or fallback.
- Map each node to a small action or condition instead of embedding heavy logic in the tree itself.
- Keep success, failure, and retry semantics explicit.

### Integrate trees into Jido workflows

- Use the tree to express control flow, not business logic internals.
- Reuse `Jido.Action` modules for leaf work whenever possible.
- Keep emitted signals or state updates visible at the edges of the tree.

### Turn sparse docs into runnable examples

- Build the smallest tree that demonstrates one branching idea clearly.
- Explain any inferred behavior as an inference, not a documented guarantee.
- Prefer examples with one selector and one fallback over a large autonomous demo.

### Review boundaries

- Keep branching semantics in `jido-behaviortree`.
- Keep agent lifecycle and runtime concerns in `jido`.
- Keep side-effectful leaf work in `jido-action`.

## Build Checklist

- Define node outcomes before implementing the nodes.
- Keep guard conditions cheap and deterministic.
- Make fallback branches observable in logs, signals, or tests.
- Add tests that exercise each branch, not just the happy path.

## Boundaries

- Do not invent advanced tree node types that the docs do not mention.
- Do not force every workflow into a tree when plain Elixir branching is clearer.
- Do not hide IO-heavy work inside guard logic.
