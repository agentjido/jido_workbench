%{
  priority: :critical,
  status: :planned,
  title: "AI Integration Decision Guide",
  repos: ["jido", "jido_ai", "req_llm"],
  tags: [:docs, :reference, :ai, :decision_guide, :llm],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/ai-integration-decision-guide",
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Evaluate when to add AI capabilities to an agent",
   "Distinguish no-AI, LLM-augmented, and LLM-driven agent patterns",
   "Plan migration paths between AI integration levels"],
  order: 20,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Decision framework for when and how to add AI capabilities: no-AI vs LLM-augmented vs LLM-driven agents",
  related: ["docs/learn/first-agent", "docs/learn/first-llm-agent"],
  prompt_overrides: %{
    document_intent: "Write a decision framework guiding developers on when and how to integrate AI into their Jido agents.",
    required_sections: ["Decision Framework", "No-AI Agents", "LLM-Augmented Agents", "LLM-Driven Agents", "Migration Paths"],
    must_include: ["Decision tree or flowchart for choosing AI integration level",
     "Concrete criteria: when deterministic logic suffices vs when LLM adds value",
     "Code patterns for each integration level",
     "Migration paths between levels without full rewrites"],
    must_avoid: ["Provider-specific setup instructions — link to provider matrix",
     "Full tutorial walkthroughs — link to Learn section"],
    required_links: ["/docs/learn/first-agent", "/docs/learn/first-llm-agent",
     "/docs/reference/provider-capability-and-fallback-matrix"],
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

Decision framework for when and how to add AI capabilities to Jido agents — covering no-AI, LLM-augmented, and LLM-driven patterns.

Cover:
- Decision criteria for choosing AI integration level
- No-AI agents: deterministic logic, full testability
- LLM-augmented agents: AI assists but doesn't drive decisions
- LLM-driven agents: AI as primary decision-maker
- Migration paths between integration levels

### Validation Criteria

- Decision framework provides clear, actionable criteria
- Each integration level includes a representative code pattern
- Migration paths show incremental steps without full rewrites
- Links to first-agent and first-llm-agent tutorials
