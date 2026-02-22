%{
  priority: :high,
  status: :outline,
  title: "Architecture Decision Guides",
  repos: ["jido"],
  tags: [:docs, :reference, :architecture, :decisions, :adr],
  audience: :advanced,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/architecture-decision-guides",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Decide when to use Jido agents vs plain GenServers",
   "Choose appropriate supervision strategies for agent workloads",
   "Evaluate state management approaches and multi-node trade-offs"],
  order: 50,
  prerequisites: ["docs/concepts/key-concepts", "docs/reference/architecture"],
  purpose: "ADR-style guides: when to use agents vs GenServers, when to add AI, supervision strategies, and state management approaches",
  related: ["docs/reference/architecture", "docs/learn/why-not-just-a-genserver"],
  prompt_overrides: %{
    document_intent: "Write ADR-style architecture decision guides helping developers choose the right patterns for their Jido systems.",
    required_sections: ["Agent vs GenServer", "Supervision Strategies", "State Management Approaches", "Multi-Node Considerations"],
    must_include: ["Decision criteria with trade-off tables",
     "When agents add value over plain GenServers",
     "Supervision strategy comparison: one-for-one, rest-for-one, dynamic supervisors",
     "State management: in-memory, ETS, persistent, distributed"],
    must_avoid: ["Reimplementing why-not-just-a-genserver content — link to it",
     "Deep OTP tutorials — assume intermediate OTP knowledge"],
    required_links: ["/docs/reference/architecture", "/docs/learn/why-not-just-a-genserver"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 2,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

ADR-style architecture decision guides for Jido — when to use agents vs GenServers, supervision strategies, state management, and multi-node considerations.

Cover:
- Agent vs GenServer decision criteria with trade-off analysis
- Supervision strategy comparison for different workload patterns
- State management approaches: in-memory, ETS, persistent, distributed
- Multi-node deployment considerations and trade-offs

### Validation Criteria

- Each decision guide provides clear criteria and trade-off tables
- Agent vs GenServer section complements (not duplicates) why-not-just-a-genserver
- Supervision strategies align with OTP best practices
- Multi-node section addresses real distributed Jido deployment scenarios
