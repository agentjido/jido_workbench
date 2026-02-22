%{
  priority: :medium,
  status: :published,
  title: "Cookbook: Tool Response",
  repos: ["jido", "jido_ai", "req_llm"],
  tags: [:docs, :guides, :cookbook, :tools, :ai],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/guides/cookbook/tool-response",
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Define a tool and handle LLM tool call responses",
   "Inject tool results back into conversation flow"],
  order: 120,
  prerequisites: ["docs/guides/cookbook/chat-response"],
  purpose: "Runnable recipe for handling LLM tool call requests and injecting results",
  related: ["docs/guides/cookbook/chat-response", "docs/guides/cookbook/weather-tool-response",
   "docs/learn/tool-use"],
  source_modules: ["Jido.AI"],
  prompt_overrides: %{
    document_intent: "Compact runnable recipe for handling tool call responses from an LLM.",
    required_sections: ["Setup", "Define Tool", "Handle Tool Call", "Inject Result"],
    must_include: ["Tool definition with schema", "Tool call handling and result injection"],
    must_avoid: ["Extended explanation — keep it recipe-compact"],
    required_links: ["/docs/guides/cookbook/weather-tool-response", "/docs/learn/tool-use"],
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

Compact runnable recipe for handling LLM tool call requests and injecting results back into conversation.

### Validation Criteria

- Code is copy-paste-runnable in Livebook
- Tool definition and call handling use current APIs
- Links to weather-tool-response for a concrete domain example
