%{
  priority: :high,
  status: :published,
  title: "Counter Agent Example",
  repos: ["jido", "jido_action"],
  tags: [:docs, :learn, :build, :example, :agents],
  audience: :beginner,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/counter-agent",
  legacy_paths: ["/build/counter-agent"],
  ecosystem_packages: ["jido", "jido_action"],
  learning_outcomes: ["Build a complete counter agent with increment, decrement, and reset",
   "Observe deterministic state transitions through sequential commands",
   "Test agent behavior with ExUnit assertions on state output"],
  order: 40,
  prerequisites: ["docs/learn/first-agent"],
  purpose: "Provide a minimal but complete agent example that reinforces the cmd/2 command model and state transition patterns",
  related: ["docs/learn/first-agent", "docs/learn/demand-tracker-agent",
   "docs/concepts/agents", "docs/concepts/actions"],
  source_files: ["lib/jido/agent.ex", "lib/jido/action.ex"],
  source_modules: ["Jido.Agent", "Jido.Action"],
  prompt_overrides: %{
    document_intent: "Write a complete counter agent example that reinforces the core Jido command model with a trivially understandable domain.",
    required_sections: ["Agent Definition", "Actions", "Running Commands", "Testing", "What to Try Next"],
    must_include: ["Full agent module with typed state (count field)",
     "Increment, decrement, and reset actions with schema validation",
     "Sequential cmd/2 calls showing state progression",
     "ExUnit test demonstrating deterministic state transitions"],
    must_avoid: ["LLM integration", "Signals and routing — keep it single-agent",
     "Production concerns"],
    required_links: ["/docs/learn/first-agent", "/docs/learn/demand-tracker-agent",
     "/docs/concepts/agents", "/docs/concepts/actions"],
    min_words: 500,
    max_words: 1_000,
    minimum_code_blocks: 4,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Minimal but complete counter agent example reinforcing the cmd/2 command model and deterministic state transitions.

Cover:
- Agent definition with typed count state
- Increment, decrement, reset actions
- Sequential command execution and state inspection
- ExUnit test for state transitions

### Validation Criteria

- Code compiles against current Jido.Agent and Jido.Action APIs
- State transitions are deterministic and testable
- Example is self-contained — copy-paste-run in a fresh project
- Links to demand-tracker as the next example with more complexity
