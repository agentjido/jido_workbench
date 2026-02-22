%{
  priority: :high,
  status: :planned,
  title: "Core Concepts Hub",
  repos: ["jido"],
  tags: [:docs, :concepts, :navigation, :hub],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/concepts",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Navigate core Jido primitives and understand how they connect",
   "Choose which concept page to read based on current need"],
  order: 1,
  prerequisites: ["docs/getting-started"],
  purpose: "Section root that orients readers across the six core Jido primitives and how they compose",
  related: ["docs/concepts/key-concepts", "docs/concepts/agents", "docs/concepts/actions",
   "docs/concepts/signals", "docs/concepts/directives", "docs/concepts/agent-runtime",
   "docs/concepts/plugins"],
  prompt_overrides: %{
    document_intent: "Create the concepts section hub that maps six core primitives and their relationships.",
    required_sections: ["Overview", "Primitive Map", "Reading Order"],
    must_include: ["One-line description of each concept page",
     "Visual or textual map showing how primitives compose",
     "Recommended reading order for newcomers"],
    must_avoid: ["Duplicating content from individual concept pages", "Long prose — this is a navigation page"],
    required_links: ["/docs/concepts/key-concepts", "/docs/concepts/agents", "/docs/concepts/actions",
     "/docs/concepts/signals", "/docs/concepts/directives", "/docs/concepts/agent-runtime",
     "/docs/concepts/plugins"],
    min_words: 200,
    max_words: 500,
    minimum_code_blocks: 0,
    diagram_policy: "recommended",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Section root for Concepts. Maps the six core Jido primitives and how they compose into agent systems.

### Validation Criteria

- Each concept page has a one-line description and link
- Shows how primitives relate (agents use actions, actions produce directives, etc.)
- Recommended reading order starts with key-concepts
