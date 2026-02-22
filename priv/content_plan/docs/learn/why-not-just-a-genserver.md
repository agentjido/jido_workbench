%{
  priority: :high,
  status: :planned,
  title: "Why Not Just a GenServer?",
  repos: ["jido"],
  tags: [:docs, :learn, :bridge, :beam, :wave_1],
  audience: :intermediate,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/learn/why-not-just-a-genserver",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Articulate what Jido adds over raw GenServer-based agents",
   "Understand the testability and determinism gains from immutable state + cmd/2",
   "Know when a plain GenServer is sufficient vs when Jido adds value"],
  order: 30,
  prerequisites: ["docs/learn/first-agent"],
  purpose: "Bridge piece that answers the most common objection from experienced Elixir developers",
  related: ["docs/concepts/agents", "docs/concepts/agent-runtime", "docs/learn/agent-fundamentals"],
  source_files: ["lib/jido/agent.ex", "lib/jido/agent_server.ex"],
  source_modules: ["Jido.Agent", "Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Answer the #1 objection from experienced Elixir devs: 'Why not just use a GenServer?'",
    required_sections: ["The GenServer Approach", "What Jido Adds", "When a GenServer Is Enough", "When Jido Shines"],
    must_include: ["Side-by-side comparison: GenServer vs Jido.Agent for the same task",
     "Highlight testability: pure cmd/2 vs process-dependent testing",
     "Highlight composability: strategy selection, plugin attachment, directive-based effects",
     "Honest acknowledgment of when plain GenServer is fine"],
    must_avoid: ["Bashing GenServer — it's a great tool", "Implying Jido replaces OTP"],
    required_links: ["/docs/concepts/agents", "/docs/concepts/agent-runtime", "/docs/learn/first-agent"],
    min_words: 500,
    max_words: 1_000,
    minimum_code_blocks: 2,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Bridge piece for experienced Elixir developers comparing Jido agents to raw GenServer implementations.

### Validation Criteria

- Includes honest side-by-side comparison with code
- Acknowledges when plain GenServer is sufficient
- Highlights testability, composability, and directive model as key differentiators
