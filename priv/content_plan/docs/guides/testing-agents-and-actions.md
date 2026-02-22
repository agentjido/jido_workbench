%{
  priority: :high,
  status: :draft,
  title: "Testing Agents and Actions",
  repos: ["jido", "jido_action"],
  tags: [:docs, :guides, :testing, :quality],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/testing-agents-and-actions",
  ecosystem_packages: ["jido", "jido_action"],
  learning_outcomes: ["Test agent state transitions deterministically without processes",
   "Test actions in isolation with schema validation assertions",
   "Test directive output without side effects or sleeping"],
  order: 40,
  prerequisites: ["docs/concepts/agents", "docs/concepts/actions"],
  purpose: "Guide for testing Jido agents, actions, and directives with deterministic, process-free strategies",
  related: ["docs/learn/actions-validation", "docs/learn/directives-scheduling",
   "docs/concepts/directives"],
  source_modules: ["Jido.Agent", "Jido.Action"],
  prompt_overrides: %{
    document_intent: "Write a how-to guide for testing agents, actions, and directives — deterministic, fast, process-free.",
    required_sections: ["Testing Philosophy", "Testing Actions in Isolation", "Testing Agent State Transitions", "Testing Directives", "Integration Testing with AgentServer"],
    must_include: ["Pure cmd/2 testing without starting processes",
     "Action input validation and error path testing",
     "Directive assertion patterns — assert content not timing",
     "Integration test patterns when process lifecycle matters"],
    must_avoid: ["LiveView testing — that's covered in the LiveView integration tutorial",
     "Performance or load testing"],
    required_links: ["/docs/learn/actions-validation", "/docs/concepts/directives",
     "/docs/learn/directives-scheduling"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 4,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

How-to guide for testing agents, actions, and directives with deterministic, process-free strategies.

Cover:
- Pure cmd/2 testing without process lifecycle
- Action input validation and error path assertions
- Directive content assertions without sleeping
- Integration tests when process lifecycle matters

### Validation Criteria

- Test patterns use current ExUnit and Jido APIs
- Demonstrates deterministic testing as a key Jido benefit
- Covers both unit and integration test levels
- Examples are copy-paste-runnable in a test file
