%{
  priority: :high,
  status: :outline,
  title: "Build an AI Chat Agent",
  repos: ["jido", "jido_ai", "req_llm"],
  tags: [:docs, :learn, :build, :ai, :chat],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/ai-chat-agent",
  legacy_paths: ["/build/ai-chat-agent"],
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Build an agent that maintains conversation context across turns",
   "Configure model provider and system prompt for chat behavior",
   "Handle streaming responses and error recovery in chat flows"],
  order: 43,
  prerequisites: ["docs/learn/first-llm-agent"],
  purpose: "Walk through building a conversational AI agent with multi-turn context, streaming, and error handling",
  related: ["docs/learn/first-llm-agent", "docs/learn/tool-use",
   "docs/reference/packages/jido-ai", "docs/guides/cookbook/chat-response"],
  source_files: ["lib/jido/ai.ex"],
  source_modules: ["Jido.AI"],
  prompt_overrides: %{
    document_intent: "Write a tutorial for building a multi-turn chat agent with Jido — context management, streaming, and graceful failure.",
    required_sections: ["Agent Setup", "Conversation Context", "System Prompt Design", "Streaming Responses", "Error Recovery", "What to Try Next"],
    must_include: ["Agent with conversation history in state",
     "System prompt configuration for chat persona",
     "Streaming response handling with LiveView or IEx",
     "Graceful degradation when provider is unavailable"],
    must_avoid: ["Tool use and function calling — that's the next guide",
     "Multi-agent coordination"],
    required_links: ["/docs/learn/first-llm-agent", "/docs/learn/tool-use",
     "/docs/reference/packages/jido-ai", "/docs/guides/cookbook/chat-response"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 4,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Tutorial for building a multi-turn conversational AI agent with context management, streaming, and error recovery.

Cover:
- Agent with conversation history state management
- System prompt configuration for chat persona
- Streaming response handling
- Graceful failure when provider is down

### Validation Criteria

- Code compiles against current jido_ai chat APIs
- Conversation context is maintained across turns in agent state
- Streaming example works in both IEx and LiveView contexts
- Links to cookbook chat-response recipe for quick reference
