%{
  priority: :critical,
  status: :planned,
  title: "Provider Capability and Fallback Matrix",
  repos: ["jido_ai", "req_llm"],
  tags: [:docs, :reference, :ai, :providers, :fallback, :matrix],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/provider-capability-and-fallback-matrix",
  ecosystem_packages: ["jido_ai", "req_llm"],
  learning_outcomes: ["Compare supported LLM providers and their capabilities",
   "Configure fallback strategies across providers",
   "Evaluate cost and latency trade-offs between providers"],
  order: 30,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Comparison of supported LLM providers, model capabilities, fallback strategies, and cost considerations",
  related: ["docs/reference/ai-integration-decision-guide", "docs/reference/configuration"],
  prompt_overrides: %{
    document_intent: "Write a reference matrix comparing LLM providers, their capabilities, and fallback configuration in Jido.",
    required_sections: ["Provider Overview", "Capability Matrix", "Fallback Configuration", "Cost Considerations"],
    must_include: ["Table comparing provider features: streaming, tool use, vision, embeddings",
     "Fallback chain configuration with code example",
     "Latency and cost comparison guidance",
     "Provider-specific notes and limitations"],
    must_avoid: ["Deep provider setup tutorials — link to relevant guides",
     "Hardcoded pricing that will quickly become stale"],
    required_links: ["/docs/reference/ai-integration-decision-guide",
     "/docs/reference/configuration"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 1,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference matrix comparing supported LLM providers, model capabilities, fallback strategies, and cost considerations.

Cover:
- Provider overview: supported providers and their integration status
- Capability matrix: streaming, tool use, vision, embeddings per provider
- Fallback configuration: chain setup and automatic failover
- Cost and latency trade-off guidance

### Validation Criteria

- Capability matrix covers all supported providers in jido_ai/req_llm
- Fallback configuration example is functional and matches current API
- Cost guidance avoids hardcoded prices that will become stale
- Links to AI integration decision guide for when-to-use context
