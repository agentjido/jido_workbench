%{
  priority: :medium,
  status: :published,
  title: "Cookbook: Chat Response",
  repos: ["jido", "jido_ai", "req_llm"],
  tags: [:docs, :guides, :cookbook, :chat, :ai],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/guides/cookbook/chat-response",
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Send a chat completion request through Jido",
   "Handle the response and extract content"],
  order: 110,
  prerequisites: ["docs/learn/first-llm-agent"],
  purpose: "Runnable recipe for basic chat completion request and response handling",
  related: ["docs/guides/cookbook/tool-response", "docs/learn/ai-chat-agent"],
  source_modules: ["Jido.AI"],
  prompt_overrides: %{
    document_intent: "Compact runnable recipe for a basic chat completion request.",
    required_sections: ["Setup", "Request", "Response"],
    must_include: ["Complete runnable code block", "Response extraction"],
    must_avoid: ["Extended explanation — keep it recipe-compact"],
    required_links: ["/docs/guides/cookbook/tool-response", "/docs/learn/ai-chat-agent"],
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

Compact runnable recipe for basic chat completion request and response handling via Jido.

### Validation Criteria

- Code is copy-paste-runnable in Livebook
- Uses current jido_ai chat APIs
- Links to tool-response recipe as a natural next step
