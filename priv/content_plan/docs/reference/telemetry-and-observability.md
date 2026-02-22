%{
  priority: :high,
  status: :draft,
  title: "Telemetry and Observability Reference",
  repos: ["jido", "jido_otel"],
  tags: [:docs, :reference, :telemetry, :observability, :opentelemetry, :metrics],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/telemetry-and-observability",
  ecosystem_packages: ["jido", "jido_otel"],
  learning_outcomes: ["Identify all telemetry events emitted by Jido",
   "Set up OpenTelemetry integration for tracing and metrics",
   "Build dashboards from Jido telemetry data"],
  order: 60,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Document telemetry events emitted by Jido, OpenTelemetry integration, metrics collection, and dashboard setup",
  related: ["docs/operations/production-readiness-checklist", "docs/reference/packages/jido-otel"],
  source_modules: ["Jido.Telemetry"],
  prompt_overrides: %{
    document_intent: "Write the definitive telemetry and observability reference for Jido systems.",
    required_sections: ["Telemetry Events", "OpenTelemetry Integration", "Metrics Collection", "Dashboard Setup"],
    must_include: ["Complete list of :telemetry events with measurements and metadata",
     "OpenTelemetry span and trace configuration",
     "Metrics collection with :telemetry_metrics",
     "Example Grafana/LiveDashboard panel configurations"],
    must_avoid: ["Generic telemetry tutorials — assume readers know :telemetry basics",
     "Production deployment specifics — link to operations section"],
    required_links: ["/docs/operations/production-readiness-checklist",
     "/docs/reference/packages/jido-otel"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 3,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Definitive telemetry and observability reference for Jido — telemetry events, OpenTelemetry integration, metrics collection, and dashboard setup.

Cover:
- Complete list of telemetry events with measurements and metadata
- OpenTelemetry span and trace configuration via jido_otel
- Metrics collection setup with :telemetry_metrics
- Dashboard configuration examples for Grafana and LiveDashboard

### Validation Criteria

- All telemetry events match `Jido.Telemetry` source module
- OpenTelemetry configuration examples are functional
- Metrics collection covers key agent lifecycle events
- Links to jido-otel package docs and production readiness checklist
