%{
  priority: :critical,
  status: :planned,
  title: "Build Your First LLM Agent",
  repos: ["jido", "jido_ai", "req_llm"],
  tags: [:docs, :learn, :tutorial, :ai, :llm, :wave_1],
  audience: :beginner,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/first-llm-agent",
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Add jido_ai and req_llm to an existing Jido project",
   "Configure a model provider and select a reasoning strategy",
   "Execute an LLM-powered agent command and interpret the result"],
  order: 12,
  prerequisites: ["docs/learn/first-agent"],
  purpose: "Extend the first-agent tutorial by adding LLM integration — the second step in the onboarding ladder",
  related: ["docs/learn/first-workflow", "docs/learn/ai-chat-agent", "docs/learn/tool-use",
   "docs/reference/packages/jido-ai", "docs/reference/configuration"],
  source_files: ["lib/jido/ai.ex", "lib/jido/ai/strategies/react.ex"],
  source_modules: ["Jido.AI", "Jido.AI.Strategies.ReAct", "ReqLLM"],
  prompt_overrides: %{
    document_intent: "Write the second onboarding tutorial — add LLM capabilities to a Jido agent.",
    required_sections: ["Add AI Dependencies", "Configure a Provider", "Choose a Strategy", "Run Your First LLM Command", "What Just Happened"],
    must_include: ["Show how to add jido_ai and req_llm deps",
     "Configure at least one provider (e.g., Anthropic or OpenAI)",
     "Use a strategy like ReAct or CoT in `use Jido.Agent`",
     "Execute a command that calls the LLM and returns structured output",
     "Explain how strategies wrap cmd/2 — the pure/effectful boundary still applies"],
    must_avoid: ["Tool use — that comes later", "Multi-agent patterns", "Production deployment concerns"],
    required_links: ["/docs/learn/first-agent", "/docs/learn/first-workflow",
     "/docs/reference/packages/jido-ai", "/docs/reference/configuration"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 4,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Second onboarding tutorial — extend the first agent with LLM capabilities.

Cover:
- Adding jido_ai and req_llm dependencies
- Provider configuration (API keys, model aliases)
- Selecting and using a reasoning strategy (ReAct, CoT)
- Running a command that calls an LLM
- Understanding how strategies maintain the pure cmd/2 contract

### Validation Criteria

- Code compiles against current jido_ai and req_llm APIs
- Provider config matches runtime.exs conventions
- Links forward to first-workflow and tool-use guides
