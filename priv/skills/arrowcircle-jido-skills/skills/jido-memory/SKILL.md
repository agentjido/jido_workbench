---
name: jido-memory
description: Builder-oriented guidance for the upstream `jido_memory` package. Use when Codex needs to add memory spaces, retrieval flows, summarization or recall hooks, or review memory boundaries in Jido applications that also use `jido`, `jido_ai`, and external storage backends.
---

# Jido Memory

`jido_memory` is the upstream Hex package name.

## Start Here

Use this skill when an agent needs to remember, recall, summarize, or retrieve prior context over time.

Good triggers:
- "Add memory to this Jido agent."
- "Choose how to store and recall prior interactions."
- "Turn the memory docs into a runnable example."
- "Review whether this memory behavior belongs in the agent loop or in storage infrastructure."

Read [references/builder-notes.md](references/builder-notes.md) before implementing when the task touches memory scope, retrieval strategy, or external storage boundaries.

## Primary Workflows

### Add memory to an agent

- Decide what should be remembered: conversation turns, tool results, summaries, domain facts, or episodic traces.
- Define when writes happen and when reads happen before wiring storage.
- Keep the agent interface small: ask for the minimum memory the next action needs.

### Choose retrieval and persistence boundaries

- Separate memory policy from the storage backend.
- Keep embeddings, vector search, or persistence adapters behind explicit interfaces.
- Use `jido_ai` docs only as conceptual support for AI-facing memory behavior; keep package-specific implementation grounded in `jido_memory`.

### Turn docs into runnable examples

- Show one write path, one retrieval path, and one agent behavior that changes because memory exists.
- Keep the example local and inspectable rather than hiding memory inside a black-box agent.
- Include one stale-data or missing-memory branch when it matters.

### Review boundaries

- Keep memory semantics in `jido_memory`.
- Keep agent state machines in `jido`.
- Keep storage engine concerns in the backend adapter or application layer.

## Build Checklist

- Define what is stored, when it expires, and who can read it.
- Choose recall criteria before choosing a backend.
- Keep retrieval payloads small and explainable.
- Add tests for cold start, duplicate writes, and missing recall results.

## Boundaries

- Do not use this skill for generic database modeling unrelated to agent memory.
- Do not mix durable domain records with ephemeral agent memory without a clear contract.
- Do not promise retrieval quality that the chosen backend or docs do not support.
