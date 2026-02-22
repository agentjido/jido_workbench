%{
  priority: :medium,
  status: :published,
  title: "Cookbook: Weather Tool Response",
  repos: ["jido", "jido_ai", "req_llm"],
  tags: [:docs, :guides, :cookbook, :tools, :ai, :weather],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/guides/cookbook/weather-tool-response",
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Build a weather lookup tool with external API integration",
   "Handle the full tool call lifecycle with a real domain example"],
  order: 130,
  prerequisites: ["docs/guides/cookbook/tool-response"],
  purpose: "Runnable recipe demonstrating a complete weather tool integration with external API call",
  related: ["docs/guides/cookbook/tool-response", "docs/learn/tool-use"],
  source_modules: ["Jido.AI"],
  prompt_overrides: %{
    document_intent: "Compact runnable recipe for a weather lookup tool with external API integration.",
    required_sections: ["Setup", "Weather Tool Definition", "External API Call", "Full Conversation Flow"],
    must_include: ["Weather tool with location parameter", "External API call pattern",
     "Complete tool call lifecycle in one conversation"],
    must_avoid: ["Extended explanation — keep it recipe-compact"],
    required_links: ["/docs/guides/cookbook/tool-response", "/docs/learn/tool-use"],
    min_words: 200,
    max_words: 500,
    minimum_code_blocks: 2,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Compact runnable recipe demonstrating a complete weather tool integration with external API call and full conversation lifecycle.

### Validation Criteria

- Code is copy-paste-runnable in Livebook
- Weather tool demonstrates real external API integration pattern
- Full tool call lifecycle is shown in one example
- Links to tool-use tutorial for deeper learning
