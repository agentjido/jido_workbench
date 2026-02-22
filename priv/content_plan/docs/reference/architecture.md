%{
  priority: :critical,
  status: :outline,
  title: "Architecture Overview",
  repos: ["jido"],
  tags: [:docs, :reference, :architecture, :supervision, :message_flow],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/architecture",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Understand the high-level system architecture and layer boundaries",
   "Trace message flow from signal ingestion through directive execution",
   "Identify supervision tree structure and extension points"],
  order: 10,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Document high-level system architecture: supervision trees, message flow, layer boundaries, and extension points",
  related: ["docs/concepts/agent-runtime", "docs/reference/architecture-decision-guides"],
  source_modules: ["Jido.Agent", "Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write the authoritative architecture overview showing how Jido's layers, supervision trees, and message flow compose.",
    required_sections: ["System Layers", "Supervision Architecture", "Message Flow", "Extension Points"],
    must_include: ["Layer diagram: data layer (agents/actions) → process layer (AgentServer) → signal layer",
     "Supervision tree structure and restart strategies",
     "End-to-end message flow from signal to effect",
     "Extension points: plugins, custom actions, signal handlers"],
    must_avoid: ["Tutorial-style walkthroughs — link to Learn section",
     "Deep-dive into individual primitives — link to concept pages"],
    required_links: ["/docs/concepts/agent-runtime", "/docs/reference/architecture-decision-guides",
     "/docs/concepts/agents", "/docs/concepts/actions"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 2,
    diagram_policy: "recommended",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Authoritative architecture overview for Jido — high-level system layers, supervision trees, message flow, and extension points.

Cover:
- System layers: data layer (agents/actions) → process layer (AgentServer) → signal layer
- Supervision tree structure and restart strategies
- End-to-end message flow from signal ingestion through directive execution
- Extension points for plugins, custom actions, and signal handlers

### Validation Criteria

- Architecture description aligns with `Jido.Agent` and `Jido.AgentServer` source modules
- Diagram shows complete layer boundaries and data flow
- Clearly distinguishes data-layer concerns from process-layer concerns
- Links to architecture-decision-guides for when-to-use guidance
