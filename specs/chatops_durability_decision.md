# ChatOps Messaging Durability Decision (ST-CHOPS-005)

## Status

- Accepted on 2026-02-18
- Scope: Epic 3 ChatOps messaging history durability posture

## Context

- ChatOps messaging currently uses `JidoMessaging.Adapters.ETS` via `AgentJido.ContentOps.Messaging` (`lib/agent_jido/content_ops/messaging.ex`).
- ETS is process-local and in-memory. Message history is lost on node restart, crash, or deploy replacement.
- The current backlog story requires an explicit production durability decision, but does not require a full migration implementation.

## Decision

- Keep the current ETS adapter in place for now.
- Defer full durable storage migration for messaging history to a follow-up story.
- Treat external channel systems (Telegram/Discord) as the operator-visible continuity source until a durable adapter is implemented.

## Why

- ETS is already integrated, low-risk for current delivery scope, and sufficient for short-window operational visibility in the ChatOps console.
- Implementing durable history now would add schema, migration, backfill, and operational complexity that is outside this story scope.
- The immediate requirement is deterministic test behavior and production handoff documentation, not historical retention guarantees.

## Consequences

- ChatOps console message timeline is best-effort and non-durable today.
- Operators must assume in-app history can reset across restarts.
- Incident and compliance workflows requiring long retention must rely on channel-native history and/or application logs until durable storage lands.

## Deferred Durable Path

- Introduce a durable messaging adapter path behind `AgentJido.ContentOps.Messaging` without changing ChatOps UI contracts.
- Add migration/retention plan (schema, indexing, retention window, backfill policy, and rollback strategy).
- Add durability smoke tests and restart-survival tests once the durable adapter exists.
