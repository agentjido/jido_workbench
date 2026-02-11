%{
  title: "Multi-Agent Workflows",
  order: 3,
  purpose: "Coordinate multiple agents working together on complex tasks",
  audience: :advanced,
  content_type: :tutorial,
  learning_outcomes: [
    "Set up parent-child agent hierarchies",
    "Route signals between agents",
    "Implement supervisor patterns for agent groups",
    "Design multi-agent coordination strategies"
  ],
  repos: ["jido"],
  source_modules: ["Jido.AgentServer", "Jido.Agent.Directive"],
  source_files: [],
  status: :planned,
  priority: :medium,
  prerequisites: ["agents", "signals", "directives", "agent-server"],
  related: ["ai-chat-agent"],
  ecosystem_packages: ["jido"],
  tags: [:guides, :multi_agent, :advanced]
}
---
## Content Brief

Building systems with multiple cooperating agents:

- Parent-child agent hierarchies via SpawnAgent directive
- Signal routing between agents
- Lifecycle monitoring and supervision
- Patterns: orchestrator, pipeline, swarm
- Example: multi-agent research assistant

### Validation Criteria
- Hierarchy APIs must match AgentServer implementation
- Directive types for spawning must match source
