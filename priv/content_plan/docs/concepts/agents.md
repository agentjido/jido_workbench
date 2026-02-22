%{
  priority: :critical,
  status: :draft,
  title: "Agents",
  repos: ["jido"],
  tags: [:docs, :concepts, :core, :agents],
  audience: :beginner,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/concepts/agents",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Explain the data-first agent model and why agents are structs",
   "Describe agent state schema, behavior contracts, and lifecycle",
   "Differentiate agent state from process runtime state"],
  order: 20,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Document the Jido agent primitive — typed state containers with behavior contracts and deterministic transitions",
  related: ["docs/concepts/actions", "docs/concepts/agent-runtime",
   "docs/learn/first-agent", "docs/learn/agent-fundamentals"],
  source_files: ["lib/jido/agent.ex"],
  source_modules: ["Jido.Agent"],
  prompt_overrides: %{
    document_intent: "Write the authoritative concept page for Jido Agents — the core data-first primitive.",
    required_sections: ["What Is an Agent?", "State Schema", "Behavior Contracts", "The cmd/2 Interface", "Agent Lifecycle"],
    must_include: ["Agents as typed structs with `use Jido.Agent`",
     "Schema definition with fields, defaults, and constraints",
     "cmd/2 as the single entry point for state transitions",
     "Why agents are data-first: testability, replayability, composability"],
    must_avoid: ["Tutorial-style step-by-step walkthroughs — link to Learn section",
     "AgentServer process details — that's the agent-runtime page"],
    required_links: ["/docs/concepts/actions", "/docs/concepts/agent-runtime",
     "/docs/learn/first-agent", "/docs/learn/agent-fundamentals"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Authoritative concept page for the Jido Agent primitive — typed state containers with behavior contracts and deterministic transitions.

Cover:
- Data-first model: agents as structs, not processes
- State schema definition and constraints
- cmd/2 as the single transition interface
- Agent lifecycle and testability benefits

### Validation Criteria

- Agent definition aligns with `Jido.Agent` source module
- cmd/2 contract explanation matches source types
- Clearly distinguishes agent state from process state
- Links to agent-runtime for process-level concerns
