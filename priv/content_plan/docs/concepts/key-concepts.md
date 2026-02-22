%{
  priority: :critical,
  status: :draft,
  title: "Key Concepts",
  repos: ["jido"],
  tags: [:docs, :concepts, :core, :overview],
  audience: :beginner,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/concepts/key-concepts",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Name the six core Jido primitives and their roles",
   "Understand the data-first agent model",
   "Trace the flow from signal to state transition to directive"],
  order: 10,
  prerequisites: [],
  purpose: "Provide a single-page mental model overview of all Jido primitives and how they compose",
  related: ["docs/concepts/agents", "docs/concepts/actions", "docs/concepts/signals",
   "docs/concepts/directives", "docs/concepts/agent-runtime", "docs/learn/first-agent"],
  source_files: ["lib/jido/agent.ex", "lib/jido/action.ex", "lib/jido/signal.ex"],
  source_modules: ["Jido.Agent", "Jido.Action", "Jido.Signal"],
  prompt_overrides: %{
    document_intent: "Write the single-page mental model overview that introduces all Jido primitives and their relationships.",
    required_sections: ["The Jido Model", "Agents", "Actions", "Signals", "Directives", "Agent Runtime", "How They Compose"],
    must_include: ["Each primitive defined in one paragraph with its role",
     "Data-first agent model: agents are structs, not processes",
     "Signal → Action → State transition → Directive flow",
     "Diagram showing primitive relationships"],
    must_avoid: ["Deep API details — link to individual concept pages",
     "Tutorial-style code walkthroughs"],
    required_links: ["/docs/concepts/agents", "/docs/concepts/actions", "/docs/concepts/signals",
     "/docs/concepts/directives", "/docs/concepts/agent-runtime", "/docs/learn/first-agent"],
    min_words: 500,
    max_words: 1_000,
    minimum_code_blocks: 1,
    diagram_policy: "recommended",
    section_density: "minimal",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Single-page mental model overview introducing all Jido primitives and how they compose into agent systems.

Cover:
- Each primitive defined in one paragraph
- Data-first agent model (agents as structs, not processes)
- Signal → Action → State → Directive flow
- Composition diagram

### Validation Criteria

- All six primitives are named and briefly defined
- Flow diagram accurately represents runtime behavior
- Links to each individual concept page for deeper detail
- Accessible to a reader with no prior Jido exposure
