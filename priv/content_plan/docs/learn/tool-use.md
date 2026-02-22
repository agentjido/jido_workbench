%{
  priority: :high,
  status: :outline,
  title: "Tool Use and Function Calling",
  repos: ["jido", "jido_ai", "req_llm"],
  tags: [:docs, :learn, :build, :ai, :tools, :function_calling],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/tool-use",
  legacy_paths: ["/build/tool-use"],
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Define tools as Jido actions available to an LLM agent",
   "Handle tool call responses and result injection",
   "Control tool access with allowlists and validation"],
  order: 44,
  prerequisites: ["docs/learn/ai-chat-agent"],
  purpose: "Teach how to expose Jido actions as callable tools for LLM agents with proper validation and access control",
  related: ["docs/learn/ai-chat-agent", "docs/learn/multi-agent-workflows",
   "docs/reference/packages/jido-ai", "docs/guides/cookbook/tool-response",
   "docs/guides/cookbook/weather-tool-response"],
  source_modules: ["Jido.AI"],
  prompt_overrides: %{
    document_intent: "Write a tutorial on exposing Jido actions as LLM-callable tools — definition, execution, result injection, and access control.",
    required_sections: ["Define a Tool", "Register Tools with an Agent", "Tool Call Flow", "Result Injection", "Access Control", "What to Try Next"],
    must_include: ["Actions as tool definitions with schema descriptions",
     "LLM tool call request and response cycle",
     "Injecting tool results back into conversation context",
     "Tool allowlisting and input validation for safety"],
    must_avoid: ["Multi-agent tool sharing — that's multi-agent-workflows",
     "MCP protocol details — that's the MCP guide"],
    required_links: ["/docs/learn/ai-chat-agent", "/docs/learn/multi-agent-workflows",
     "/docs/guides/cookbook/tool-response", "/docs/guides/cookbook/weather-tool-response"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 4,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Tutorial on exposing Jido actions as LLM-callable tools with proper validation, result injection, and access control.

Cover:
- Defining actions as tool specifications
- Tool call request/response lifecycle
- Injecting tool results into conversation context
- Allowlisting and input validation

### Validation Criteria

- Tool definition examples use current jido_ai tool APIs
- Tool call lifecycle matches actual LLM provider behavior
- Access control guidance prevents arbitrary tool execution
- Links to cookbook recipes for working tool-response examples
