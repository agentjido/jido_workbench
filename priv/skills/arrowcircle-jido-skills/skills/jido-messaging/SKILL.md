---
name: jido-messaging
description: Builder-oriented guidance for the upstream `jido_messaging` package. Use when Codex needs to plan or review messaging adapters, bridge Jido signals onto external transports, or keep delivery semantics, retries, and routing boundaries explicit for Jido-based systems.
---

# Jido Messaging

`jido_messaging` is the upstream Hex package name.

## Start Here

Use this skill when the task is about moving Jido signals across external transports such as queues, brokers, or pub/sub systems.

Good triggers:
- "Bridge Jido signals onto a message bus."
- "Design a messaging adapter for this Jido app."
- "Review delivery semantics and retries for external dispatch."
- "Figure out whether this logic belongs in `jido_messaging` or `jido_signal`."

Public docs for this package are thin. Require a concrete target transport or integration before getting specific, and keep any unsupported transport behavior explicit as an assumption.

## Primary Workflows

### Design an adapter boundary

- Start from the signal contract, then map it onto transport topics, subjects, or queues.
- Keep serialization, headers, and correlation ids explicit.
- Separate transport delivery from core signal creation and validation.

### Define delivery semantics

- Decide whether the workflow needs at-most-once, at-least-once, ordering, or replay guarantees.
- Keep retry and dead-letter behavior in the adapter boundary, not in the signal schema.
- Surface ack or failure information in a way the application can observe.

### Review package boundaries

- Keep signal definitions in `jido-signal`.
- Keep transport adapters and delivery concerns in `jido-messaging`.
- Keep domain-specific message handling in the application layer.

## Build Checklist

- Identify the transport first.
- Define serialization and routing keys before coding.
- Make correlation and retry behavior observable.
- Add tests for invalid payloads, redelivery, and missing consumers.

## Boundaries

- Do not invent support for a broker or transport that the docs do not mention.
- Do not collapse signal schema and transport wiring into one module.
- Do not hide delivery guarantees or failure modes from callers.
