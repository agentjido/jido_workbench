%{
  priority: :high,
  status: :outline,
  title: "Multi-Agent Workflows",
  repos: ["jido", "jido_signal"],
  tags: [:docs, :learn, :build, :multi_agent, :coordination],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/multi-agent-workflows",
  legacy_paths: ["/build/multi-agent-workflows"],
  ecosystem_packages: ["jido", "jido_signal"],
  learning_outcomes: ["Coordinate multiple agents through signal-based communication",
   "Design agent boundaries that prevent tight coupling",
   "Handle failure and partial completion in multi-agent flows"],
  order: 45,
  prerequisites: ["docs/learn/signals-routing"],
  purpose: "Teach multi-agent coordination patterns using signals, with clear agent boundary design and failure handling",
  related: ["docs/learn/signals-routing", "docs/learn/tool-use",
   "docs/concepts/signals", "docs/concepts/agent-runtime",
   "docs/learn/reference-architectures"],
  source_files: ["lib/jido/signal.ex", "lib/jido/agent_server.ex"],
  source_modules: ["Jido.Signal", "Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write a tutorial on multi-agent coordination — signal-based communication, boundary design, and failure handling across agents.",
    required_sections: ["When to Use Multiple Agents", "Agent Boundary Design", "Signal-Based Coordination", "Orchestration Patterns", "Failure and Partial Completion", "What to Try Next"],
    must_include: ["Criteria for splitting vs combining agent responsibilities",
     "Signal-based coordination between two or more agents",
     "Orchestrator pattern vs peer-to-peer coordination",
     "Handling partial failures and compensation logic"],
    must_avoid: ["Single-agent patterns — those are covered in earlier tutorials",
     "Production deployment specifics"],
    required_links: ["/docs/learn/signals-routing", "/docs/concepts/signals",
     "/docs/concepts/agent-runtime", "/docs/learn/reference-architectures"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "recommended",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Tutorial on multi-agent coordination patterns using signal-based communication with clear boundary design and failure handling.

Cover:
- When and why to split into multiple agents
- Signal-based coordination patterns
- Orchestrator vs peer-to-peer approaches
- Partial failure handling and compensation

### Validation Criteria

- Coordination patterns use current Jido.Signal and AgentServer APIs
- Boundary design criteria are concrete and actionable
- Failure scenarios include compensation or rollback guidance
- Diagram shows agent communication flow
