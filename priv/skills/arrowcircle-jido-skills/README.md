# Jido Skills

Builder-oriented Codex skills for the Jido ecosystem.

This repository contains a generated catalog of skills for the public Jido ecosystem, plus a router skill that helps choose the right package skill for a task. The current catalog was generated automatically by ChatGPT Codex from public Jido ecosystem material, including Jido docs, HexDocs, `hex.pm`, and related source references, then validated with the local `skill-creator` tooling.

## What Is Included

- 12 package skills for the current Jido ecosystem:
  - `llm-db`
  - `req-llm`
  - `jido-action`
  - `jido-signal`
  - `jido`
  - `jido-browser`
  - `jido-memory`
  - `jido-behaviortree`
  - `ash-jido`
  - `jido-studio`
  - `jido-messaging`
  - `jido-otel`
- 1 router skill:
  - `jido-skill-router`
- 1 generation prompt:
  - [`source/prompts.md`](source/prompts.md)

## How To Use

If you already know the package boundary, invoke the package skill directly.

Examples:

```text
Use $jido-action to scaffold a new Jido.Action for sending a webhook.
Use $req-llm to add streaming support for Anthropic responses.
Use $ash-jido to expose these Ash actions to a Jido agent.
```

If you do not know which package skill to start with, use the router skill first.

```text
Use $jido-skill-router to choose the right Jido ecosystem skills for an Ash-triggered agent workflow.
Use $jido-skill-router to route this task across Jido memory, signals, and OpenTelemetry.
```

The router skill will:

- identify the anchor package skill
- pull in adjacent skills only when the task crosses their boundaries
- avoid loading the entire ecosystem by default

## Repository Layout

- [`skills`](skills): all generated skills
- [`skills/jido-skill-router`](skills/jido-skill-router): router skill for package selection and multi-skill handoffs
- [`skills/jido-skill-router/references/skill-manifest.yaml`](skills/jido-skill-router/references/skill-manifest.yaml): machine-readable manifest for the current skill catalog
- [`source/prompts.md`](source/prompts.md): generation prompt used to create the package skills

## Notes

- This catalog was generated automatically by ChatGPT Codex.
- It is grounded in public Jido docs, but some ecosystem packages currently have thinner public documentation than others.
- When docs are thin, the corresponding skills are intentionally narrow instead of guessing unsupported behavior.
- Treat this repository as a practical starting point and review package-specific guidance before treating it as authoritative.

## Regenerating

To regenerate or extend the catalog:

1. Update [`source/prompts.md`](source/prompts.md).
2. Run the prompt through Codex or another compatible agent.
3. Validate generated `SKILL.md` files with the local `skill-creator` validator.
