%{
  priority: :high,
  status: :published,
  title: "Signals, Routing, and Agent Communication",
  repos: ["jido", "jido_signal"],
  tags: [:docs, :learn, :training, :signals, :routing, :coordination],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/signals-routing",
  legacy_paths: ["/training/signals-routing"],
  ecosystem_packages: ["jido", "jido_signal"],
  learning_outcomes: ["Model cross-agent events with stable signal naming",
   "Route signals to actions without tight coupling",
   "Design idempotent handlers for duplicate or delayed delivery"],
  order: 22,
  prerequisites: ["docs/learn/actions-validation"],
  purpose: "Teach explicit signal contracts and routing strategies that keep producer and consumer responsibilities decoupled",
  related: ["docs/concepts/signals", "docs/learn/directives-scheduling",
   "docs/concepts/agent-runtime", "docs/learn/multi-agent-workflows"],
  source_files: ["lib/jido/signal.ex", "lib/jido/signal/router.ex"],
  source_modules: ["Jido.Signal", "Jido.Signal.Router"],
  prompt_overrides: %{
    document_intent: "Write the training module on signal-based agent coordination — naming, routing, idempotency, and observability.",
    required_sections: ["Signal Taxonomy", "Route Design", "Payload Discipline", "Idempotency", "Observability", "Hands-on Exercise"],
    must_include: ["Separate intent signals (`*.command`) from fact signals (`*.changed`)",
     "Small, explicit routing tables",
     "Consistent identifiers and timestamps in payloads",
     "Dedupe keys and monotonic checks for idempotent handlers",
     "Two-agent order fulfillment exercise with duplicate event simulation"],
    must_avoid: ["Directive and scheduling patterns — that's the next module", "Production telemetry setup"],
    required_links: ["/docs/concepts/signals", "/docs/learn/directives-scheduling",
     "/docs/learn/actions-validation"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Training module on coordinating agents through explicit signal contracts and decoupled routing strategies.

Cover:
- Signal taxonomy: intent vs fact signals
- Route design with small, explicit tables
- Payload discipline with identifiers and timestamps
- Idempotency via dedupe keys and monotonic checks
- Two-agent order fulfillment exercise

### Validation Criteria

- Signal naming patterns align with `Jido.Signal` source conventions
- Routing examples use `Jido.Signal.Router` API correctly
- Idempotency guidance includes concrete duplicate-delivery handling
- Links forward to directives-scheduling as the next training module
