%{
  title: "Building an AI Chat Agent",
  order: 1,
  purpose: "Build a conversational AI agent with LLM-powered responses",
  audience: :intermediate,
  content_type: :tutorial,
  learning_outcomes: [
    "Configure an agent with Jido AI for LLM integration",
    "Handle conversation threads with Jido.Thread",
    "Implement tool use via actions",
    "Stream responses to a LiveView UI"
  ],
  repos: ["jido", "jido_ai"],
  source_modules: ["Jido.AI", "Jido.Thread", "Jido.Agent"],
  source_files: [],
  status: :planned,
  priority: :high,
  prerequisites: ["agents", "actions", "signals"],
  related: ["tool-use", "multi-agent-workflows"],
  ecosystem_packages: ["jido", "jido_ai"],
  tags: [:guides, :ai, :chat, :llm]
}
---
## Content Brief

End-to-end tutorial building a chat agent:

1. Define a ChatAgent with conversation state
2. Configure JidoAI with an LLM provider (e.g., Anthropic)
3. Create actions for sending messages and receiving responses
4. Use Jido.Thread for conversation history
5. Wire it up to a Phoenix LiveView for streaming output

### Validation Criteria
- JidoAI configuration must match current API
- Thread API must match Jido.Thread source
