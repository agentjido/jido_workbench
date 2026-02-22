%{
  priority: :high,
  status: :draft,
  title: "Glossary",
  repos: ["jido"],
  tags: [:docs, :reference, :glossary, :terminology],
  audience: :beginner,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/glossary",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Look up definitions of Jido-specific terms",
   "Understand terminology used consistently across documentation"],
  order: 80,
  prerequisites: [],
  purpose: "Alphabetical glossary of Jido-specific terms and their definitions",
  related: ["docs/concepts/key-concepts"],
  prompt_overrides: %{
    document_intent: "Write an alphabetical glossary defining all Jido-specific terms used across the documentation.",
    required_sections: ["Terms A-Z"],
    must_include: ["All core primitives: Agent, Action, Signal, Directive, Plugin, AgentServer",
     "Key concepts: cmd/2, state schema, behavior contract, signal dispatch",
     "Ecosystem terms: jido_ai, jido_memory, req_llm where relevant",
     "Cross-references to concept pages for deeper explanations"],
    must_avoid: ["Long explanations — keep definitions concise (1-2 sentences)",
     "Duplicating concept page content — link to them instead"],
    required_links: ["/docs/concepts/key-concepts"],
    min_words: 400,
    max_words: 800,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Alphabetical glossary of Jido-specific terms — concise definitions with cross-references to concept pages.

Cover:
- Core primitives: Agent, Action, Signal, Directive, Plugin, AgentServer
- Key interfaces: cmd/2, state schema, behavior contracts
- Ecosystem terms: jido_ai, jido_memory, req_llm
- Cross-references to full concept pages

### Validation Criteria

- All terms used in documentation are defined
- Definitions are concise (1-2 sentences each)
- Each term links to the relevant concept page where applicable
- Alphabetical ordering is consistent
