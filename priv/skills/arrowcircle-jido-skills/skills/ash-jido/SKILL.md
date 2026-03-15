---
name: ash-jido
description: Builder-oriented guidance for the upstream `ash_jido` package. Use when Codex needs to expose Ash actions as Jido actions, wire Ash resources into agent workflows, emit or consume signals around Ash changes, or review boundary decisions between Ash domains and Jido agents.
---

# Ash Jido

`ash_jido` is the upstream Hex package name.

## Start Here

Use this skill when the task crosses the Ash and Jido boundary.

Good triggers:
- "Expose these Ash actions to a Jido agent."
- "Generate Jido actions from an Ash resource."
- "Trigger an agent from an Ash change."
- "Review whether this behavior belongs in Ash or in Jido."

Read [references/builder-notes.md](references/builder-notes.md) before implementing when authorization, tenant context, or signal routing is involved.

## Primary Workflows

### Expose Ash actions to Jido

- Start from the Ash action contract and generate only the agent-facing surface you actually need.
- Preserve Ash domain, actor, and tenant context at the boundary.
- Keep generated action names clear and stable so signal routes stay readable.

### Trigger agents from Ash changes

- Emit signals after successful Ash actions rather than mixing agent orchestration into the changeset body.
- Pass only the identifiers and domain facts the agent needs.
- Keep long-running work in Jido, not in the Ash transaction.

### Turn docs into runnable examples

- Prefer one Ash resource and one Jido agent.
- Show the extension declaration, generated action, and one signal-driven workflow.
- Include the required Ash context explicitly in the example.

### Review boundaries

- Keep business data rules and authorization in Ash.
- Keep long-running orchestration and reactive workflows in Jido.
- Keep signal contracts in `jido-signal`.

## Build Checklist

- Confirm which Ash actions should be exposed and why.
- Preserve `domain`, `actor`, and `tenant` context where needed.
- Keep generated Jido action names and descriptions obvious.
- Add tests for authorization, domain context, and signal routing.

## Boundaries

- Do not bypass Ash policies or validations in generated agent paths.
- Do not move domain logic out of Ash just because Jido can call it.
- Do not let long-running external work execute inside the Ash transaction boundary.
