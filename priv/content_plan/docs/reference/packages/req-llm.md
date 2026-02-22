%{
  priority: :critical,
  status: :outline,
  title: "Package Reference: req_llm",
  repos: ["req_llm"],
  tags: [:docs, :reference, :packages, :req_llm, :http, :llm, :providers, :req],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/req-llm",
  ecosystem_packages: ["req_llm"],
  learning_outcomes: [
    "Understand the purpose of the req_llm package",
    "Know how to install and configure req_llm",
    "Identify supported LLM providers and their adapters",
    "Understand how req_llm integrates with Req and jido_ai"
  ],
  order: 50,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the req_llm package covering HTTP client adapters for LLM providers as a Req plugin.",
  related: [
    "docs/reference/packages/jido-ai",
    "docs/reference/provider-capability-and-fallback-matrix"
  ],
  source_modules: ["ReqLLM"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the req_llm package — an HTTP client adapter (Req plugin) for communicating with LLM providers.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose as a Req plugin for LLM provider communication",
      "Mix dependency installation snippet",
      "Summary of supported providers and adapter modules",
      "Configuration options for provider endpoints and authentication",
      "Usage examples showing direct provider requests"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for req_llm",
      "GitHub repository",
      "docs/reference/packages/jido-ai",
      "docs/reference/provider-capability-and-fallback-matrix"
    ],
    min_words: 600,
    max_words: 1200,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference for the `req_llm` package — an HTTP client adapter built as a Req plugin for communicating with LLM providers. Covers supported providers (OpenAI, Anthropic, Google, etc.), adapter configuration, authentication, and how req_llm serves as the transport layer beneath jido_ai. This package handles the low-level HTTP communication so higher-level packages can focus on AI logic.

### Validation Criteria

- Clearly explains the package's role as a Req plugin for LLM HTTP communication
- Includes a working Mix dependency installation snippet
- Documents supported providers and their adapter modules
- Lists configuration options for endpoints and authentication
- Provides at least 3 code examples showing provider requests
- Links to jido_ai package reference and provider capability matrix
- Does not duplicate full API docs from HexDocs
