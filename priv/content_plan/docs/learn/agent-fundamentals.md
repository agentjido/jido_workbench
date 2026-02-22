%{
  priority: :high,
  status: :published,
  title: "Agent Fundamentals on the BEAM",
  repos: ["jido"],
  tags: [:docs, :learn, :training, :agents, :otp, :beam],
  audience: :beginner,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/agent-fundamentals",
  legacy_paths: ["/training/agent-fundamentals"],
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Explain why Jido models agents as data first",
   "Differentiate process lifecycle from agent state lifecycle",
   "Define a minimal agent schema and signal routing table"],
  order: 20,
  prerequisites: ["docs/learn/first-agent"],
  purpose: "Teach the core Jido mental model: agents as data, actions as transitions, and supervision-managed execution boundaries",
  related: ["docs/concepts/agents", "docs/concepts/agent-runtime",
   "docs/learn/actions-validation", "docs/learn/why-not-just-a-genserver"],
  source_files: ["lib/jido/agent.ex", "lib/jido/agent_server.ex"],
  source_modules: ["Jido.Agent", "Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write the foundational training module that establishes the Jido mental model — agents as typed state containers with deterministic transitions.",
    required_sections: ["Mental Model", "State Schema", "Signal Routing", "Deterministic Execution", "Failure and Supervision", "Hands-on Exercise"],
    must_include: ["Agents as typed state containers plus behavior contracts",
     "Immutable transitions for debuggability and replayability",
     "Signal route tables mapping events to action modules",
     "Isolation of side effects from domain transitions",
     "InventoryAgent exercise with schema, routes, and guards"],
    must_avoid: ["LLM integration details", "Production deployment patterns — those come in the production-readiness module"],
    required_links: ["/docs/concepts/agents", "/docs/concepts/agent-runtime",
     "/docs/learn/actions-validation", "/docs/learn/first-agent"],
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

Foundational training module covering the Jido mental model: agents as data, actions as state transitions, schema-driven design, and signal routing.

Cover:
- Agents as typed state containers with behavior contracts
- Immutable state transitions and deterministic execution
- Signal routing tables and predictable naming
- Supervisor strategies for process-level recovery
- Hands-on InventoryAgent exercise

### Validation Criteria

- Mental model explanation aligns with `Jido.Agent` source implementation
- Schema and routing examples use current API patterns
- Exercise produces deterministic state diffs without side effects
- Links forward to actions-validation as the next training module
