%{
  title: "Tool Use and Function Calling",
  order: 60,
  purpose: "Show how to expose actions as LLM-callable tools with schema-safe execution and error handling",
  audience: :intermediate,
  content_type: :tutorial,
  learning_outcomes: [
    "Define tool-callable action contracts",
    "Generate and validate tool schemas",
    "Handle tool results and failures deterministically"
  ],
  repos: ["jido", "jido_ai", "jido_action"],
  source_modules: ["Jido.AI", "Jido.Action"],
  source_files: ["lib/jido/action.ex", "config/runtime.exs"],
  status: :outline,
  priority: :high,
  prerequisites: ["build/ai-chat-agent", "docs/actions"],
  related: [
    "build/multi-agent-workflows",
    "operate/testing-agents-and-actions",
    "reference/configuration"
  ],
  ecosystem_packages: ["jido", "jido_ai", "jido_action"],
  tags: [:build, :ai, :tools, :function_calling]
}
---
## Content Brief

Implementation guide for the tool-call loop: model request -> tool selection -> action execution -> structured result.

### Validation Criteria

- Tool schema generation reflects actual action parameter contracts
- Includes failure patterns (timeouts, invalid params, transient provider errors)
- Includes at least one multi-tool example path
