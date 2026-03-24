%{
  priority: :high,
  status: :outline,
  title: "Livebook Authoring Standards",
  repos: ["agent_jido"],
  tags: [:docs, :contributors, :livebook, :quality],
  audience: :beginner,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/contributors/livebook-authoring-standards",
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Apply the canonical runnable Livebook format for Jido docs",
   "Know which runtime pattern, metadata, and drift test expectations to use"],
  order: 5,
  prerequisites: ["docs/contributors/_hub"],
  purpose: "Contributor-facing standard for runnable Livebook docs notebooks, including setup, runtime pattern, metadata, and drift testing expectations",
  related: ["docs/contributors/package-quality-standards", "docs/contributors/contributing",
   "docs/guides/cookbook/chat-response"],
  prompt_overrides: %{
    document_intent: "Write the canonical contributor-facing standard for Jido docs Livebooks.",
    required_sections: ["Fast Path Checklist", "Canonical Notebook Shape", "Setup Cell",
     "Runtime Pattern For Livebook", "Livebook Metadata", "Drift Tests"],
    must_include: ["Self-contained notebook rule",
     "Mix.install plus Logger.configure(level: :warning)",
     "Jido.start() plus Jido.start_agent(Jido.default_instance(), ...)",
     "Guidance on stable public APIs versus advanced internals",
     "Expectation for one drift test per runnable notebook"],
    must_avoid: ["Package QA policy duplication", "Long philosophical narrative"],
    required_links: ["/docs/contributors/package-quality-standards",
     "/docs/contributors/contributing", "/community"],
    min_words: 700,
    max_words: 1_400,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "compact",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Contributor-facing standard for Jido docs Livebooks.

### Validation Criteria

- Defines one canonical beginner-friendly Livebook structure
- Uses the default runtime pattern for notebook examples
- Separates stable public API usage from advanced internals
- Documents livebook metadata and drift test expectations clearly
