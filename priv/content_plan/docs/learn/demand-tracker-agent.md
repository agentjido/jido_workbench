%{
  priority: :high,
  status: :published,
  title: "Demand Tracker Agent Example",
  repos: ["jido", "jido_action"],
  tags: [:docs, :learn, :build, :example, :agents, :directives],
  audience: :beginner,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/demand-tracker-agent",
  legacy_paths: ["/build/demand-tracker-agent"],
  ecosystem_packages: ["jido", "jido_action"],
  learning_outcomes: ["Build a demand tracker agent with boost, cool, and auto-decay actions",
   "Use directives to schedule recurring behavior",
   "Observe signal emission and directive-based side effects"],
  order: 41,
  prerequisites: ["docs/learn/counter-agent"],
  purpose: "Demonstrate directives, signal emission, and scheduled behavior through a practical demand tracking example",
  related: ["docs/learn/counter-agent", "docs/learn/directives-scheduling",
   "docs/learn/liveview-integration", "docs/concepts/directives"],
  source_files: ["lib/jido/agent.ex", "lib/jido/agent/directive.ex"],
  source_modules: ["Jido.Agent", "Jido.Agent.Directive"],
  prompt_overrides: %{
    document_intent: "Write a demand tracker example that introduces directives, scheduling, and signal emission beyond simple state transitions.",
    required_sections: ["Agent Definition", "Boost and Cool Actions", "Auto-Decay with Directives", "Signal Emission", "Testing Directives", "What to Try Next"],
    must_include: ["Agent with demand_score, auto_decay_enabled, and event log fields",
     "Boost and cool actions that modify demand_score",
     "Auto-decay toggle that emits schedule directives",
     "Signal emission on state changes",
     "Tests asserting directive content rather than sleeping"],
    must_avoid: ["LiveView integration — that's a separate tutorial",
     "Production supervision patterns"],
    required_links: ["/docs/learn/counter-agent", "/docs/concepts/directives",
     "/docs/learn/directives-scheduling", "/docs/learn/liveview-integration"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 4,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Demand tracker agent example demonstrating directives, scheduled behavior, and signal emission beyond simple state transitions.

Cover:
- Agent with demand score and auto-decay toggle
- Boost, cool, and auto-decay actions
- Schedule directives for recurring behavior
- Signal emission on state changes
- Testing directive output

### Validation Criteria

- Code compiles and demonstrates directive-based side effects
- Auto-decay loop is state-controlled with safe termination
- Tests assert directive payloads, not timing
- Links forward to directives-scheduling training and LiveView integration
