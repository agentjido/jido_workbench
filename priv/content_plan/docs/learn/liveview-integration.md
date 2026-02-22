%{
  priority: :high,
  status: :published,
  title: "LiveView and Jido Integration Patterns",
  repos: ["jido", "agent_jido"],
  tags: [:docs, :learn, :training, :liveview, :integration, :ui],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/liveview-integration",
  legacy_paths: ["/training/liveview-integration"],
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Model UI events as agent commands",
   "Render from immutable agent state in socket assigns",
   "Integrate emitted signals into real-time UI feedback"],
  order: 24,
  prerequisites: ["docs/learn/directives-scheduling"],
  purpose: "Teach how to connect LiveView UIs to agent state transitions with deterministic rendering and event-driven updates",
  related: ["docs/learn/production-readiness", "docs/learn/demand-tracker-agent",
   "docs/learn/counter-agent", "docs/concepts/agent-runtime"],
  source_files: ["lib/agent_jido_web/live/"],
  source_modules: ["AgentJidoWeb"],
  prompt_overrides: %{
    document_intent: "Write the training module on wiring LiveView UIs to Jido agents — command mapping, state rendering, directive visibility, and concurrency.",
    required_sections: ["Command Boundary", "State Rendering", "Directive Visibility", "Concurrency Handling", "Testing", "Hands-on Exercise"],
    must_include: ["Map each UI intent to a single agent command",
     "Render from the latest immutable agent struct only",
     "Surface emitted/scheduled work in UI logs for debugging",
     "Guard against stale events and rapid clicks",
     "Demand tracker LiveView exercise with buttons and directive panel"],
    must_avoid: ["Production supervision and telemetry — that's the next module", "Complex multi-agent UI patterns"],
    required_links: ["/docs/learn/production-readiness", "/docs/learn/directives-scheduling",
     "/docs/learn/demand-tracker-agent", "/docs/learn/counter-agent"],
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

Training module on connecting LiveView UIs to Jido agent state transitions with deterministic rendering and event-driven updates.

Cover:
- Mapping UI events to agent commands
- Rendering from immutable agent state in socket assigns
- Surfacing directive outcomes for debugging
- Concurrency guards for stale events
- Demand tracker LiveView exercise

### Validation Criteria

- Command mapping examples use current LiveView `handle_event/3` patterns
- Socket assigns hold immutable agent state, not derived copies
- Exercise includes LiveView test asserting multi-step user flow
- Links forward to production-readiness as the next training module
