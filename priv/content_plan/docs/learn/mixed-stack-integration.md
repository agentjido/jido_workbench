%{
  priority: :medium,
  status: :outline,
  title: "Mixed-Stack Integration",
  repos: ["jido", "jido_signal"],
  tags: [:docs, :learn, :build, :integration, :mixed_stack],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/learn/mixed-stack-integration",
  legacy_paths: ["/build/mixed-stack-integration"],
  ecosystem_packages: ["jido", "jido_signal"],
  learning_outcomes: ["Integrate Jido agents with Python, Node.js, and other language services",
   "Choose between API-first and event-first handoff patterns",
   "Define stable contracts at language boundaries"],
  order: 60,
  prerequisites: ["docs/learn/reference-architectures"],
  purpose: "Show how to integrate Jido agent orchestration with non-Elixir services through stable boundary contracts",
  related: ["docs/learn/reference-architectures", "docs/guides/mixed-stack-runbooks",
   "docs/operations/security-and-governance", "docs/concepts/signals"],
  source_modules: ["Jido.Signal", "Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write a guide on integrating Jido with external language ecosystems — boundary patterns, contract design, and rollout strategies.",
    required_sections: ["Where This Guide Fits", "API-First Handoff", "Event-First Handoff", "Contract Design", "Rollout Checklist"],
    must_include: ["API-first pattern: external service calls bounded endpoint, signal emitted into Jido",
     "Event-first pattern: external service publishes events, Jido subscribes",
     "Contract handoff code examples with Signal.new!",
     "Rollout checklist for pilot workflows"],
    must_avoid: ["Reimplementing content from reference-architectures",
     "Vendor-specific SDK instructions"],
    required_links: ["/docs/learn/reference-architectures", "/docs/guides/mixed-stack-runbooks",
     "/docs/operations/security-and-governance"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "recommended",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Guide on integrating Jido agent orchestration with Python, Node.js, and other non-Elixir services through stable boundary contracts.

Cover:
- API-first and event-first handoff patterns
- Signal-based contract design at language boundaries
- Code examples for boundary handoff
- Rollout checklist for pilot integrations

### Validation Criteria

- Boundary patterns match existing published mixed-stack-integration content
- Contract examples use current Jido.Signal API
- Diagrams show data flow across language boundaries
- Links to mixed-stack-runbooks for operational guidance
