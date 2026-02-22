%{
  priority: :high,
  status: :planned,
  title: "Package Reference: jido_otel",
  repos: ["jido_otel"],
  tags: [:docs, :reference, :packages, :jido_otel, :opentelemetry, :traces, :spans, :metrics, :observability],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido-otel",
  ecosystem_packages: ["jido_otel"],
  learning_outcomes: [
    "Understand the purpose of the jido_otel package",
    "Know how to install and configure jido_otel for tracing and metrics",
    "Identify key modules for OpenTelemetry integration",
    "Understand how observability integrates with the agent runtime"
  ],
  order: 100,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido_otel package covering OpenTelemetry integration for traces, spans, and metrics.",
  related: [
    "docs/reference/telemetry-and-observability",
    "docs/operations/production-readiness-checklist",
    "docs/reference/packages/jido"
  ],
  source_modules: ["Jido.OTel"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido_otel package — OpenTelemetry integration providing traces, spans, and metrics for Jido agent observability.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet",
      "Summary of tracing, span, and metrics modules",
      "Configuration options for exporters and sampling",
      "Usage examples showing trace instrumentation and metric collection"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido_otel",
      "GitHub repository",
      "docs/reference/telemetry-and-observability",
      "docs/operations/production-readiness-checklist"
    ],
    min_words: 600,
    max_words: 1200,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference for the `jido_otel` package — OpenTelemetry integration for the Jido ecosystem. Covers trace instrumentation, span creation, metrics collection, and exporter configuration to enable full observability of agent behavior in production. This package provides the telemetry foundation for monitoring, debugging, and optimizing agent systems.

### Validation Criteria

- Clearly explains the package's role in agent observability via OpenTelemetry
- Includes a working Mix dependency installation snippet
- Documents key modules for tracing, spans, and metrics
- Lists configuration options for exporters and sampling
- Provides at least 3 code examples showing trace instrumentation and metrics
- Links to the telemetry reference and production readiness checklist
- Does not duplicate full API docs from HexDocs
