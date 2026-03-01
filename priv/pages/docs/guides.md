%{
  description: "Task-oriented implementation guides for building and operating Jido agent systems.",
  title: "Guides",
  category: :docs,
  legacy_paths: ["/docs/getting-started/guides"],
  tags: [:docs, :guides],
  order: 30
}
---

You know what you want to build - these guides show you how. Unlike [Learn tutorials](/docs/learn) that teach progressively or [Concepts](/docs/concepts) that explain primitives, guides are task-oriented. Pick the one that matches your problem and go.

## Implementation patterns

- [Testing agents and actions](/docs/guides/testing-agents-and-actions) - unit and integration test patterns for agents, actions, and workflows
- [Long-running agent workflows](/docs/guides/long-running-agent-workflows) - managing stateful agents across restarts and deployments
- [Retries, backpressure, and failure recovery](/docs/guides/retries-backpressure-and-failure-recovery) - resilience patterns for production agent systems
- [Persistence, memory, and vector search](/docs/guides/persistence-memory-and-vector-search) - storing agent state, conversation history, and semantic search
- [MCP integration](/docs/guides/mcp-integration) - connecting agents to Model Context Protocol servers
- [Mixed-stack runbooks](/docs/guides/mixed-stack-runbooks) - integrating Jido with non-Elixir services
- [Troubleshooting and debugging playbook](/docs/guides/troubleshooting-and-debugging-playbook) - diagnosing common issues in agent systems

## Cookbook

Short recipes for common tasks. Each one is self-contained and copy-pasteable.

- [Cookbook index](/docs/guides/cookbook) - browse all recipes
- [Chat response](/docs/guides/cookbook/chat-response) - handle streaming chat completions
- [Tool response](/docs/guides/cookbook/tool-response) - process tool call results
- [Weather tool response](/docs/guides/cookbook/weather-tool-response) - end-to-end tool use example

## Next steps

- [Concepts](/docs/concepts) - understand the primitives behind these patterns
- [Operations](/docs/operations) - deploy, monitor, and scale your agent systems
