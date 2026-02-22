%{
  priority: :critical,
  status: :draft,
  title: "Agent Runtime (AgentServer)",
  repos: ["jido"],
  tags: [:docs, :concepts, :core, :runtime, :agent_server],
  audience: :intermediate,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/concepts/agent-runtime",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Explain how AgentServer bridges agent data to OTP process lifecycle",
   "Describe signal dispatch, command execution, and directive interpretation flow",
   "Understand supervision integration and failure recovery"],
  order: 60,
  prerequisites: ["docs/concepts/agents", "docs/concepts/actions"],
  purpose: "Document the AgentServer runtime — the OTP process that hosts agent state, dispatches signals, and interprets directives",
  related: ["docs/concepts/agents", "docs/concepts/signals", "docs/concepts/directives",
   "docs/learn/production-readiness", "docs/learn/why-not-just-a-genserver"],
  source_files: ["lib/jido/agent_server.ex"],
  source_modules: ["Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write the authoritative concept page for the Jido AgentServer — the OTP runtime that hosts agents.",
    required_sections: ["What Is AgentServer?", "Signal Dispatch", "Command Execution", "Directive Interpretation", "Supervision Integration", "Process vs Data Lifecycle"],
    must_include: ["AgentServer as a GenServer hosting agent struct state",
     "Signal dispatch: receive signal → route to action → execute cmd/2",
     "Directive interpretation: process emit/schedule directives after state transition",
     "Supervision tree integration and restart strategies",
     "Clear separation: agent data lifecycle vs process lifecycle"],
    must_avoid: ["Reimplementing agent or action concept content",
     "Production telemetry details — that's the operations section"],
    required_links: ["/docs/concepts/agents", "/docs/concepts/signals",
     "/docs/concepts/directives", "/docs/learn/production-readiness",
     "/docs/learn/why-not-just-a-genserver"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "recommended",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Authoritative concept page for the Jido AgentServer — the OTP process that hosts agent state, dispatches signals, and interprets directives.

Cover:
- AgentServer as GenServer hosting agent struct
- Signal dispatch → action routing → cmd/2 execution flow
- Directive interpretation after state transitions
- Supervision integration and restart strategies
- Process lifecycle vs agent data lifecycle

### Validation Criteria

- Architecture description aligns with `Jido.AgentServer` source
- Signal dispatch flow matches actual implementation
- Diagram shows complete signal → action → directive → effect pipeline
- Links to why-not-just-a-genserver for the GenServer comparison
