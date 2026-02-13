%{
  title: "Multi-Agent Workflows",
  order: 70,
  purpose: "Teach practical coordination patterns across multiple agents with explicit routing and orchestration semantics",
  audience: :advanced,
  content_type: :tutorial,
  learning_outcomes: [
    "Design parent-child or peer coordination patterns",
    "Route signals across workflow boundaries safely",
    "Select orchestration strategy based on failure and latency constraints"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.AgentServer", "Jido.Agent.Directive"],
  source_files: ["lib/jido/agent_server.ex", "lib/jido/agent/directive.ex"],
  status: :outline,
  priority: :high,
  prerequisites: ["docs/agents", "docs/signals", "docs/directives", "build/ai-chat-agent"],
  related: [
    "docs/agent-server",
    "docs/long-running-agent-workflows",
    "build/reference-architectures"
  ],
  ecosystem_packages: ["jido", "jido_signal", "agent_jido"],
  destination_route: "/build/multi-agent-workflows",
  destination_collection: :pages,
  tags: [:build, :multi_agent, :coordination, :advanced]
}
---
## Content Brief

Pattern guide for orchestrator, pipeline, and delegated-agent architectures.

### Validation Criteria

- Uses directive and signal semantics that match current source behavior
- Includes at least one failure-containment pattern
- Connects directly to Operate runbooks for post-launch handling
