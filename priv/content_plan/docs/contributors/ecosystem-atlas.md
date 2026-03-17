%{
  priority: :high,
  status: :outline,
  title: "Ecosystem Atlas",
  repos: ["agent_jido"],
  tags: [:docs, :contributors, :ecosystem, :ownership],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/contributors/ecosystem-atlas",
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai", "req_llm"],
  learning_outcomes: ["Find the current public package roster and ownership map",
   "Distinguish support label from release state and package purpose"],
  order: 2,
  prerequisites: [],
  purpose: "Contributor-facing public package roster organized by the current brainstorm ecosystem groups with support level, owner, release state, and purpose",
  related: ["docs/contributors/package-support-levels", "docs/contributors/roadmap",
   "ecosystem/overview"],
  prompt_overrides: %{
    document_intent: "Write the Ecosystem Atlas page as a concise contributor-facing package roster.",
    required_sections: ["Integration / Framework", "Core / Runtime", "AI / LLM",
     "Messaging", "Harness / CLI", "Planning / Control", "Runtime / Interfaces",
     "Runtime / Distributed", "Memory / Storage", "Observability / Telemetry",
     "Developer Tools / UI", "Automation / Bots", "Evaluation / Testing"],
    must_include: ["One compact markdown table per category",
     "Columns for package, support, owner, release, and purpose",
     "Short note that deeper package pages live under `/ecosystem`",
     "Group names aligned to the current `jido_brainstorm` ecosystem inventory"],
    must_avoid: ["Private packages", "Long package-by-package narrative"],
    required_links: ["/ecosystem", "/docs/contributors/package-support-levels",
     "/docs/contributors/roadmap"],
    min_words: 500,
    max_words: 1200,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Contributor-facing package roster for the public Jido ecosystem.

### Validation Criteria

- Includes only public packages
- Groups packages by the current brainstorm ecosystem sections
- Shows owner handles and release state distinctly from support level
