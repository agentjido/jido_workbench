%{
  title: "Tool Use & Function Calling",
  order: 2,
  purpose: "Give AI agents the ability to call tools and take actions in the world",
  audience: :intermediate,
  content_type: :tutorial,
  learning_outcomes: [
    "Define actions as LLM-callable tools",
    "Configure tool schemas for function calling",
    "Handle tool call results in agent workflows",
    "Chain multiple tool calls in a single interaction"
  ],
  repos: ["jido", "jido_ai", "jido_action"],
  source_modules: ["Jido.AI", "Jido.Action"],
  source_files: [],
  status: :planned,
  priority: :high,
  prerequisites: ["actions", "ai-chat-agent"],
  related: ["multi-agent-workflows"],
  ecosystem_packages: ["jido", "jido_ai", "jido_action"],
  tags: [:guides, :ai, :tools, :function_calling]
}
---
## Content Brief

How to make Jido actions available as LLM tools:

- Annotating actions for tool use
- Tool schema generation from action parameter schemas
- The tool call → action execution → result loop
- Multi-step tool use chains
- Error handling in tool calls

### Validation Criteria
- Tool schema format must match JidoAI implementation
- Action-to-tool mapping must reflect actual code path
