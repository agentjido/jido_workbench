%{
  priority: :high,
  status: :outline,
  title: "Troubleshooting and Debugging Playbook",
  repos: ["jido"],
  tags: [:docs, :guides, :troubleshooting, :debugging],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/troubleshooting-and-debugging-playbook",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Diagnose common agent system failures systematically",
   "Use IEx, telemetry, and logging to trace signal and command flow",
   "Resolve frequent configuration, routing, and state errors"],
  order: 50,
  prerequisites: ["docs/concepts/agent-runtime"],
  purpose: "Provide a structured playbook for diagnosing and resolving common Jido agent system issues",
  related: ["docs/guides/testing-agents-and-actions", "docs/operations/incident-playbooks",
   "docs/reference/telemetry-and-observability"],
  source_modules: ["Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write a troubleshooting playbook organized by symptom — common failures, debugging techniques, and resolution steps.",
    required_sections: ["Debugging Approach", "Common Symptoms", "Signal and Routing Issues", "State and Action Errors", "Configuration Problems", "IEx Debugging Recipes"],
    must_include: ["Symptom → cause → resolution format for each issue",
     "IEx recipes for inspecting agent state and signal flow",
     "Telemetry-based debugging for command latency and failures",
     "Common configuration mistakes and fixes"],
    must_avoid: ["Production incident response — that's the operations section",
     "Basic Elixir debugging techniques"],
    required_links: ["/docs/guides/testing-agents-and-actions",
     "/docs/operations/incident-playbooks",
     "/docs/reference/telemetry-and-observability"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Troubleshooting playbook organized by symptom with debugging techniques and resolution steps for common Jido agent issues.

Cover:
- Symptom → cause → resolution format
- IEx recipes for state and signal inspection
- Telemetry-based debugging techniques
- Common configuration mistakes

### Validation Criteria

- Each symptom has a concrete cause and resolution
- IEx recipes are copy-paste-runnable
- Covers signal routing, state, action, and config issue categories
- Links to incident playbooks for production-level response
