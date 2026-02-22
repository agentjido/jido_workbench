%{
  priority: :critical,
  status: :review,
  title: "Build Your First Agent (no LLM)",
  repos: ["jido", "jido_action"],
  tags: [:docs, :learn, :tutorial, :agents, :wave_1],
  audience: :beginner,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/first-agent",
  legacy_paths: ["/build/first-agent"],
  ecosystem_packages: ["jido", "jido_action"],
  learning_outcomes: ["Define an agent module with typed state",
   "Implement an action and execute it via cmd/2",
   "Interpret updated state and returned directives"],
  order: 11,
  prerequisites: ["docs/learn/installation"],
  purpose: "Walk a new user from setup to a running agent workflow that demonstrates the Jido command model",
  related: ["docs/concepts/key-concepts", "docs/learn/counter-agent",
   "docs/learn/agent-fundamentals", "docs/concepts/actions"],
  source_files: ["lib/jido/agent.ex", "lib/jido_action.ex"],
  source_modules: ["Jido.Agent", "Jido.Action"],
  prompt_overrides: %{
    document_intent: "Write the canonical hello-world tutorial for Jido — no LLM, pure deterministic agent.",
    required_sections: ["Define Your Agent", "Create an Action", "Execute with cmd/2", "Understand the Output"],
    must_include: ["Create a simple counter-like agent with `use Jido.Agent`",
     "Add one action with schema-validated params",
     "Execute `cmd/2` and inspect deterministic state transitions",
     "Explain directive output and why side effects are deferred"],
    must_avoid: ["LLM integration — that's the next guide", "Complex multi-action workflows"],
    required_links: ["/docs/learn/first-llm-agent", "/docs/learn/counter-agent",
     "/docs/concepts/agents", "/docs/concepts/actions"],
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

Canonical hello-world build flow.

Cover:
- Create a simple counter-like agent with `use Jido.Agent`
- Add one action with schema-validated params
- Execute `cmd/2` and inspect deterministic state transitions
- Explain directive output and why side effects are deferred

### Validation Criteria

- Code compiles against the current Jido API
- `cmd/2` contract explanation matches source types and behavior
- Page links forward to counter example and fundamentals training
