%{
  priority: :high,
  status: :outline,
  title: "Docs Overview",
  repos: ["agent_jido"],
  tags: [:docs, :navigation, :self_serve, :hub_getting_started, :format_markdown, :wave_1],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Navigate the Jido docs structure effectively", "Choose the right docs path for current intent",
   "Find next-step implementation and operations guidance quickly"],
  order: 1,
  prerequisites: [],
  purpose: "Provide a self-serve map of canonical docs paths and how they connect to Learn, Concepts, Guides, Operations, and Reference",
  related: ["docs/getting-started", "docs/concepts/_hub", "docs/guides/_hub", "docs/reference/_hub",
   "docs/learn/_hub", "ecosystem/overview"],
  source_files: ["priv/content_plan/**/*.md"],
  source_modules: ["AgentJido.ContentPlan"],
  prompt_overrides: %{
    document_intent: "Create the entry page for /docs that routes users by intent: learn, build, troubleshoot, or verify exact API details.",
    required_sections: ["Welcome", "Section Map", "Quick Links by Intent"],
    must_include: ["Link to each docs section with a one-line description of what it covers",
     "Intent-based routing: 'I want to learn' → Learn, 'I need to build' → Learn/Guides, 'Something is broken' → Guides/Operations, 'I need exact details' → Reference"],
    must_avoid: ["Duplicating content from section hubs", "Long prose — this is a navigation page"],
    required_links: ["/docs/getting-started", "/docs/learn", "/docs/concepts", "/docs/guides",
     "/docs/operations", "/docs/reference", "/docs/community"],
    min_words: 200,
    max_words: 500,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Entry page for `/docs` that routes users by intent: learn, build, troubleshoot, or verify exact API details.

### Validation Criteria

- Includes clear routing for beginner, implementation, and operations intents
- Links each section with one-line description
- Keeps page copy compact and action-oriented
