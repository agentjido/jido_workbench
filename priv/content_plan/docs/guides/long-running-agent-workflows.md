%{
  priority: :high,
  status: :outline,
  title: "Long-Running Agent Workflows",
  repos: ["jido"],
  tags: [:docs, :guides, :workflows, :long_running],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/long-running-agent-workflows",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Design agent workflows that span minutes, hours, or days",
   "Handle process restarts without losing workflow state",
   "Implement checkpointing and resumption patterns"],
  order: 20,
  prerequisites: ["docs/learn/directives-scheduling", "docs/concepts/agent-runtime"],
  purpose: "Guide for designing and operating agent workflows that outlive individual process lifetimes",
  related: ["docs/guides/retries-backpressure-and-failure-recovery",
   "docs/guides/persistence-memory-and-vector-search",
   "docs/learn/multi-agent-workflows"],
  source_modules: ["Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write a how-to guide for long-running agent workflows — checkpointing, resumption, and state persistence across restarts.",
    required_sections: ["When Workflows Outlive Processes", "Checkpointing Patterns", "Resumption After Restart", "Timeout and Cancellation", "Monitoring Long Workflows"],
    must_include: ["State persistence strategies for workflow continuity",
     "Checkpoint-and-resume pattern with directive-based scheduling",
     "Timeout handling for stalled workflows",
     "Monitoring and alerting for long-running operations"],
    must_avoid: ["Basic scheduling concepts — assume reader knows directives",
     "Database schema design — link to data-storage reference"],
    required_links: ["/docs/guides/retries-backpressure-and-failure-recovery",
     "/docs/guides/persistence-memory-and-vector-search",
     "/docs/learn/directives-scheduling"],
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

How-to guide for designing agent workflows that span long durations and survive process restarts.

Cover:
- Checkpointing state for workflow continuity
- Resumption patterns after process restart
- Timeout and cancellation handling
- Monitoring long-running operations

### Validation Criteria

- Checkpointing pattern is implementable with current Jido APIs
- Resumption handles both clean and crash restarts
- Timeout guidance prevents stalled workflows
- Links to persistence guide for storage details
