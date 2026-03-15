---
name: jido-signal
description: Builder-oriented guidance for the upstream `jido_signal` package. Use when Codex needs to define signal schemas, route or dispatch events, bridge Jido signals to buses or transports, or review `jido_signal` boundaries versus `jido`, `jido_messaging`, and application code.
---

# Jido Signal

`jido_signal` is the upstream Hex package name.

## Start Here

Use this skill when the task is about signal structure, validation, dispatch, or event boundaries.

Good triggers:
- "Define the signal shape for this workflow."
- "Bridge agent events onto PubSub, webhooks, or another bus."
- "Turn the signal docs into a runnable example."
- "Review whether this event contract belongs in `jido_signal` or in app code."

Read [references/builder-notes.md](references/builder-notes.md) before implementing when the task touches CloudEvents-like structure, signal versioning, or external delivery boundaries.

## Primary Workflows

### Define signal contracts

- Start with event intent: what happened, who emitted it, and what downstream consumers must rely on.
- Keep the public signal shape stable even if internal producers change.
- Prefer explicit type, source, subject, and data conventions over loose maps.

### Build routing and dispatch flows

- Separate signal creation from transport delivery.
- Keep signal validation close to the producer boundary.
- Translate into PubSub, queues, or webhooks in adapter code, not in the signal definition itself.

### Turn docs into runnable examples

- Show one producer, one signal payload, and one consumer.
- Include serialization or validation only when it changes the design.
- Demonstrate failure handling for malformed or missing fields when that is central to the example.

### Review boundaries

- Keep event contracts and signaling semantics in `jido_signal`.
- Keep transport-specific adapters in `jido-messaging` or app code.
- Keep agent planning and execution control in `jido`.

## Build Checklist

- Name the event in domain language.
- Define the minimum stable payload.
- Choose versioning or compatibility rules before publishing widely.
- Test serialization, validation, and consumer expectations.

## Boundaries

- Do not use this skill to design an entire broker stack.
- Do not overload one signal type with unrelated payload shapes.
- Do not let consumer-specific fields leak back into the core signal contract.
