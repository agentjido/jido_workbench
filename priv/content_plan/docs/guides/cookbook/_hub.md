%{
  priority: :medium,
  status: :outline,
  title: "Cookbook",
  repos: ["jido", "jido_ai"],
  tags: [:docs, :guides, :cookbook, :recipes],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/cookbook",
  ecosystem_packages: ["jido", "jido_ai"],
  learning_outcomes: ["Find runnable recipes for common implementation tasks",
   "Copy and adapt cookbook patterns for production use"],
  order: 100,
  prerequisites: ["docs/learn/first-agent"],
  purpose: "Index page for cookbook recipes — compact, runnable examples for common Jido implementation tasks",
  related: ["docs/guides/cookbook/chat-response", "docs/guides/cookbook/tool-response",
   "docs/guides/cookbook/weather-tool-response"],
  prompt_overrides: %{
    document_intent: "Create the cookbook index page that lists all runnable recipes with one-line descriptions.",
    required_sections: ["Overview", "Recipe Index"],
    must_include: ["One-line description and link for each recipe",
     "Note that recipes are Livebook-compatible"],
    must_avoid: ["Duplicating recipe content", "Long explanations"],
    required_links: ["/docs/guides/cookbook/chat-response", "/docs/guides/cookbook/tool-response",
     "/docs/guides/cookbook/weather-tool-response"],
    min_words: 100,
    max_words: 300,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Cookbook index page listing all runnable recipes with one-line descriptions.

### Validation Criteria

- All published recipes are listed with descriptions
- Recipes are identified as Livebook-compatible
- Links to each recipe work correctly
