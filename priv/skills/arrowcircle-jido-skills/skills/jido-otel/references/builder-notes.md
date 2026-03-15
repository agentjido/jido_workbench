# Jido OpenTelemetry Builder Notes

## Use This Reference For

- Mapping Jido observability hooks onto OpenTelemetry spans.
- Keeping exporter configuration separate from the tracer implementation.
- Reviewing which metadata should become attributes or events.

## Source Highlights

- Core `jido` exposes `Jido.Observe` and `Jido.Observe.Tracer` while intentionally staying free of direct OpenTelemetry dependencies.
- The observability docs explicitly describe a separate `jido_otel` package as the concrete tracer integration point.
- Correlation fields such as trace id, span id, parent span id, and causation id are already part of the Jido observability model.

## Implementation Heuristics

- Instrument documented lifecycle hooks first.
- Treat exception spans and redaction settings as first-class concerns.
- Keep exporter setup in config, not embedded in tracing logic.
- Favor stable attribute names over ad hoc metadata dumping.

## Narrowing Rules

- If the task is general dashboarding or alerting, this skill is too low-level.
- If the task changes core Jido observability APIs, verify the docs before proposing it.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/jido/observability.html
- https://hexdocs.pm/jido/Jido.Observe.html
- https://hexdocs.pm/jido/Jido.Observe.Tracer.html
