# Sagents Competitor Briefing

## Snapshot

- Repo: `sagents-ai/sagents`
- Stars: 103 (2026-02-20 UTC snapshot)
- Language: Elixir
- Positioning: interactive Elixir agent framework for OTP-supervised, LiveView-friendly multi-agent applications.

## Executive Briefing

Sagents is an early-stage but strategically relevant Elixir competitor. It is opinionated around interactive AI applications and BEAM-native process supervision. Its standout profile includes:

1. GenServer/OTP agent runtime with supervisor-driven lifecycle.
2. Middleware-centric extension model.
3. Built-in HITL interruption/approval flows.
4. Real-time PubSub + Presence integration for UI-first agent experiences.

## Ecosystem Surface

- Core `Agent` config + `AgentServer` execution runtime.
- Middleware modules for filesystem, HITL, subagents, summarization, and task support.
- Persistence generators for conversation/state storage schemas.
- LiveView helper generators and debug event ecosystem.
- Companion ecosystem references (`agents_demo`, `sagents_live_debugger`).

## Detailed Feature List

### Runtime and architecture

- Each agent runs as supervised OTP process (GenServer model).
- Clear separation of immutable agent configuration and mutable runtime state.
- Registry/supervision design supports dynamic session-oriented agent processes.

### Orchestration and agent topology

- SubAgent middleware enables delegation to specialized child agents.
- Parent/sub-agent interruption propagation supports controlled delegation.
- Middleware chain controls pre-model and post-model behavior.

### State and persistence

- Explicit state serialization/deserialization guidance.
- Mix generators scaffold conversation, agent-state, and display-message persistence.
- Auto-save and manual save patterns documented for run lifecycle.

### Human-in-the-loop and safety

- HITL middleware can interrupt protected tool calls.
- Resume path supports approve/edit/reject decisions.
- Interrupt data flows are integrated into LiveView event handling.

### Tools and extensibility

- Middleware can contribute tools and runtime hooks.
- Virtual filesystem middleware provides scoped file operations.
- Custom middleware behavior enables extension without core fork.

### Real-time UX and observability

- PubSub broadcasts for status, messages, tool events, and token usage.
- Debug topics include state snapshots and middleware action events.
- Phoenix Presence integration supports viewer-aware lifecycle controls.

### Deployment/runtime profile

- Strong fit for Phoenix interactive products.
- Background/non-UI usage supported but primary value is interactive orchestration.
- Depends on LangChain Elixir model/tool integrations.

## Operational Profile Summary

- Strongest areas: OTP-native process model, LiveView interaction patterns, HITL and event streaming.
- Moderate areas: early ecosystem maturity and limited adoption signals.
- Operational style: interactive app framework for Elixir teams.

## Strengths

1. BEAM-native supervision and process isolation for per-conversation agents.
2. Excellent UI/event integration model for LiveView products.
3. Practical HITL middleware with explicit approval semantics.
4. Good persistence scaffolding for conversation-oriented applications.

## Risks and Gaps

1. Very early adoption stage (small community footprint to date).
2. Ecosystem depth and long-term compatibility are still emerging.
3. Heavy focus on interactive patterns may not map to all batch/automation workloads.

## Jido Implications

- Sagents validates demand for Elixir-first interactive agent frameworks.
- Jido should maintain clear differentiation on ecosystem breadth, reliability depth, and production architecture.
- UI/event and HITL ergonomics are competitive areas where Sagents is opinionated and concrete.

## Primary Sources

- https://github.com/sagents-ai/sagents
- https://raw.githubusercontent.com/sagents-ai/sagents/main/README.md
- https://raw.githubusercontent.com/sagents-ai/sagents/main/docs/architecture.md
- https://raw.githubusercontent.com/sagents-ai/sagents/main/docs/conversations_architecture.md
- https://raw.githubusercontent.com/sagents-ai/sagents/main/docs/lifecycle.md
- https://raw.githubusercontent.com/sagents-ai/sagents/main/docs/middleware.md
- https://raw.githubusercontent.com/sagents-ai/sagents/main/docs/middleware_messaging.md
- https://raw.githubusercontent.com/sagents-ai/sagents/main/docs/persistence.md
- https://raw.githubusercontent.com/sagents-ai/sagents/main/docs/pubsub_presence.md
