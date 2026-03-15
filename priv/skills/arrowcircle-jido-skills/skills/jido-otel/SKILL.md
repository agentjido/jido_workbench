---
name: jido-otel
description: Builder-oriented guidance for the upstream `jido_otel` package. Use when Codex needs to add OpenTelemetry tracing to Jido applications, implement a tracer backend for Jido observability hooks, or review how spans, correlation ids, and exported telemetry should cross package boundaries.
---

# Jido OpenTelemetry

`jido_otel` is the upstream Hex package name.

## Start Here

Use this skill when the task is about tracing, spans, correlation ids, or wiring Jido observability into an OpenTelemetry pipeline.

Good triggers:
- "Add OpenTelemetry tracing to this Jido app."
- "Implement the Jido tracer backend."
- "Review which spans and attributes this workflow should emit."
- "Turn the observability docs into a working tracer example."

Read [references/builder-notes.md](references/builder-notes.md) before coding when the task touches `Jido.Observe`, `Jido.Observe.Tracer`, or exporter configuration.

## Primary Workflows

### Implement tracing cleanly

- Start from the Jido observability hooks and span lifecycle instead of instrumenting random call sites.
- Keep tracer code focused on translating Jido metadata into OpenTelemetry spans and events.
- Preserve correlation ids and causation metadata when the docs expose them.

### Configure exporters and runtime behavior

- Separate tracer implementation from exporter configuration.
- Keep production configuration explicit: endpoint, batching, redaction, and log level.
- Prefer safe defaults that do not break core Jido behavior when tracing is unavailable.

### Turn docs into runnable examples

- Show one action or agent workflow producing spans.
- Include the Jido tracer configuration and one exporter setup.
- Keep examples small enough to inspect trace structure by hand.

### Review boundaries

- Keep the observability facade in `jido`.
- Keep OpenTelemetry-specific integration in `jido-otel`.
- Keep product-specific dashboards and alerting in the application layer.

## Build Checklist

- Confirm which Jido events should create spans.
- Propagate correlation metadata consistently.
- Decide what must be redacted before exporting.
- Add tests or examples for success, exception, and missing-exporter paths.

## Boundaries

- Do not add direct OpenTelemetry dependencies to core `jido` behavior that the docs intentionally keep separate.
- Do not emit high-cardinality attributes without a clear need.
- Do not assume metrics or logs behavior beyond what the tracer integration documents.
