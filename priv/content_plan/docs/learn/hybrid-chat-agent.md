%{
  priority: :high,
  status: :drafted,
  title: "Build a Hybrid Chat Agent",
  repos: ["jido", "jido_ai", "req_llm"],
  tags: [:docs, :learn, :build, :ai, :chat, :reasoning],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/hybrid-chat-agent",
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: [
    "Reuse one chat agent process for both quick and deep reasoning turns",
    "Escalate individual requests with per-request llm_opts instead of rebuilding the agent",
    "Inspect stored conversation state and optional request metadata after a reasoning-heavy turn"
  ],
  order: 51,
  prerequisites: ["docs/learn/ai-chat-agent"],
  purpose: "Teach the simplest honest pattern for mixing light chat turns and heavier reasoning turns in one Livebook-friendly chat agent",
  related: [
    "docs/learn/ai-chat-agent",
    "docs/learn/ai-agent-with-tools",
    "docs/guides/cookbook/chat-response",
    "docs/reference/configuration"
  ],
  source_files: [
    "deps/jido_ai/lib/jido_ai/agent.ex",
    "deps/jido_ai/lib/jido_ai/request.ex",
    "deps/req_llm/guides/openai.md"
  ],
  source_modules: [
    "Jido.AI.Agent",
    "Jido.AI.Request",
    "ReqLLM.Providers.OpenAI"
  ],
  prompt_overrides: %{
    document_intent: "Write a runnable Livebook tutorial that mixes quick chat turns and deeper reasoning turns on one Jido AI agent.",
    required_sections: [
      "Setup",
      "Quick Turn",
      "Deep Turn",
      "Conversation Inspection",
      "When to Use This Pattern"
    ],
    must_include: [
      "One agent pid reused across all turns",
      "Per-request llm_opts escalation for the deep turn",
      "Conversation inspection after multiple turns",
      "A clear note that request_transformer is the advanced follow-up"
    ],
    must_avoid: [
      "Lifecycle hooks in the main path",
      "Manual conversation-history string building",
      "Provider switching in the beginner flow"
    ],
    required_links: [
      "/docs/learn/ai-chat-agent",
      "/docs/learn/ai-agent-with-tools",
      "/docs/guides/cookbook/chat-response",
      "/docs/reference/configuration"
    ],
    min_words: 700,
    max_words: 1_300,
    minimum_code_blocks: 6,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Runnable Livebook tutorial for a hybrid chat agent that uses the same conversation process for quick content turns and deeper reasoning turns.

Cover:
- One `Jido.AI.Agent`
- Per-request `llm_opts` escalation
- One shared conversation thread
- Optional inspection of deep-turn request metadata

### Validation Criteria

- Notebook runs end to end in Livebook with or without credentials configured
- Deep turn uses request-scoped reasoning controls rather than a separate agent
- Conversation inspection proves all turns stayed on the same pid
- Links clearly position this as a follow-up to the basic AI chat guide
