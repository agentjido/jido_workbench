%{
  priority: :high,
  status: :published,
  title: "Directives, Scheduling, and Time-Based Behavior",
  repos: ["jido"],
  tags: [:docs, :learn, :training, :directives, :scheduling],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/directives-scheduling",
  legacy_paths: ["/training/directives-scheduling"],
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Use directives to request side effects declaratively",
   "Implement recurring behavior with schedule chains",
   "Stop scheduled loops safely using state-driven guards"],
  order: 23,
  prerequisites: ["docs/learn/signals-routing"],
  purpose: "Teach declarative side-effect management with directives, including schedule-driven loops and safe shutdown logic",
  related: ["docs/concepts/directives", "docs/learn/liveview-integration",
   "docs/learn/demand-tracker-agent", "docs/learn/counter-agent"],
  source_files: ["lib/jido/agent/directive.ex"],
  source_modules: ["Jido.Agent.Directive"],
  prompt_overrides: %{
    document_intent: "Write the training module on directives — declarative side effects, scheduling, loop controls, and testing time-based behavior.",
    required_sections: ["Directive Fundamentals", "Scheduling Model", "Loop Controls", "Failure Handling", "Testing Time", "Hands-on Exercise"],
    must_include: ["Emit, schedule, and compose side effect instructions",
     "One-shot schedules and self-rescheduling loops",
     "State flags and termination conditions for loop control",
     "Retry windows, jitter, and dead-letter strategies",
     "Demand tracker auto-decay exercise with directive assertions"],
    must_avoid: ["LiveView integration — that's the next module", "Production supervision patterns"],
    required_links: ["/docs/concepts/directives", "/docs/learn/liveview-integration",
     "/docs/learn/signals-routing", "/docs/learn/demand-tracker-agent"],
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

Training module on declarative side-effect management with directives, schedule-driven loops, and safe termination.

Cover:
- Emit, schedule, and compose directive instructions
- One-shot and self-rescheduling loop patterns
- State-driven loop guards and termination conditions
- Testing directives without sleeping
- Demand tracker auto-decay exercise

### Validation Criteria

- Directive patterns align with `Jido.Agent.Directive` source API
- Scheduling examples show both one-shot and recurring patterns
- Exercise demonstrates state-controlled loop stop behavior
- Links forward to liveview-integration as the next training module
