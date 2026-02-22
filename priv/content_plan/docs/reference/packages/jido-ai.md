%{
  priority: :critical,
  status: :outline,
  title: "Package Reference: jido_ai",
  repos: ["jido_ai"],
  tags: [:docs, :reference, :packages, :jido_ai, :ai, :llm, :chat, :providers, :tool_use],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido-ai",
  ecosystem_packages: ["jido_ai"],
  learning_outcomes: [
    "Understand the purpose of the jido_ai package",
    "Know how to install and configure jido_ai with LLM providers",
    "Identify key modules for chat completions, tool use, and provider management",
    "Understand how jido_ai integrates with the core agent framework"
  ],
  order: 40,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido_ai package covering AI/LLM integration, chat completions, tool use, and provider configuration.",
  related: [
    "docs/learn/first-llm-agent",
    "docs/learn/ai-chat-agent",
    "docs/reference/packages/req-llm",
    "docs/reference/packages/jido"
  ],
  source_modules: ["Jido.AI"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido_ai package — the AI/LLM integration layer providing chat completions, tool use, and multi-provider support.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet",
      "Summary of AI modules: chat completions, tool use, provider adapters",
      "Configuration options for LLM providers and API keys",
      "Usage examples showing chat completion and tool use"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido_ai",
      "GitHub repository",
      "docs/learn/first-llm-agent",
      "docs/reference/packages/req-llm"
    ],
    min_words: 800,
    max_words: 1500,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference for the `jido_ai` package — the AI/LLM integration layer for the Jido ecosystem. Covers chat completions, tool use, provider configuration (OpenAI, Anthropic, Google, etc.), and how jido_ai connects LLM capabilities to the agent framework. This package enables agents to leverage large language models for reasoning, generation, and decision-making.

### Validation Criteria

- Clearly explains the package's role as the AI/LLM integration layer
- Includes a working Mix dependency installation snippet
- Documents key modules for chat, tool use, and provider management
- Lists configuration options including provider API key setup
- Provides at least 3 code examples showing chat completions and tool use
- Links to learning tutorials and the req_llm package reference
- Does not duplicate full API docs from HexDocs
