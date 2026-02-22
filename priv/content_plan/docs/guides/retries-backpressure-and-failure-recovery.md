%{
  priority: :high,
  status: :draft,
  title: "Retries, Backpressure, and Failure Recovery",
  repos: ["jido"],
  tags: [:docs, :guides, :reliability, :failure_recovery],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/retries-backpressure-and-failure-recovery",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Implement retry strategies with backoff and jitter",
   "Apply backpressure to protect agent systems from overload",
   "Design recovery paths for transient and persistent failures"],
  order: 10,
  prerequisites: ["docs/concepts/agent-runtime", "docs/learn/directives-scheduling"],
  purpose: "Guide for implementing retry, backpressure, and failure recovery patterns in Jido agent systems",
  related: ["docs/operations/production-readiness-checklist", "docs/learn/production-readiness",
   "docs/guides/long-running-agent-workflows"],
  source_files: ["lib/jido/agent_server.ex"],
  source_modules: ["Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write a how-to guide for retry, backpressure, and failure recovery patterns in Jido agents.",
    required_sections: ["Retry Strategies", "Backoff and Jitter", "Backpressure Patterns", "Transient vs Persistent Failures", "Recovery Paths"],
    must_include: ["Exponential backoff with jitter implementation",
     "Queue depth monitoring and shedding strategies",
     "Circuit breaker pattern for external dependencies",
     "Dead-letter handling for unrecoverable signals"],
    must_avoid: ["Basic agent concepts — assume reader knows fundamentals",
     "Production monitoring setup — that's the operations section"],
    required_links: ["/docs/operations/production-readiness-checklist",
     "/docs/learn/production-readiness", "/docs/guides/long-running-agent-workflows"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

How-to guide for retry, backpressure, and failure recovery patterns in Jido agent systems.

Cover:
- Retry strategies with exponential backoff and jitter
- Backpressure via queue depth monitoring and shedding
- Circuit breaker pattern for external dependencies
- Dead-letter handling for unrecoverable failures

### Validation Criteria

- Retry patterns are implementable with current Jido APIs
- Backpressure guidance references AgentServer queue behavior
- Recovery paths cover both transient and persistent failures
- Links to production-readiness for operational context
