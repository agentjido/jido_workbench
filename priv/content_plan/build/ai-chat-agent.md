%{
  title: "Build an AI Chat Agent",
  order: 50,
  purpose: "Guide teams through building a conversational agent with model integration, tool use, and UI delivery",
  audience: :intermediate,
  content_type: :tutorial,
  learning_outcomes: [
    "Configure Jido AI providers in a production-safe way",
    "Model conversation state and thread boundaries",
    "Integrate tool calls and response handling in one workflow"
  ],
  repos: ["jido", "jido_ai", "agent_jido"],
  source_modules: ["Jido.AI", "Jido.Thread", "Jido.Agent"],
  source_files: ["config/runtime.exs", "lib/agent_jido_web/live/jido_training_module_live.ex"],
  status: :outline,
  priority: :high,
  prerequisites: ["build/first-agent", "docs/agents", "docs/actions", "docs/signals"],
  related: [
    "build/tool-use",
    "build/multi-agent-workflows",
    "build/product-feature-blueprints",
    "reference/configuration"
  ],
  ecosystem_packages: ["jido", "jido_ai", "req_llm", "agent_jido"],
  tags: [:build, :ai, :chat, :llm]
}
---
## Content Brief

End-to-end implementation tutorial for conversational features.

### Validation Criteria

- Provider configuration examples match supported adapters
- Tool-call loop mirrors current action execution model
- Includes explicit reliability caveats for production launch readiness
