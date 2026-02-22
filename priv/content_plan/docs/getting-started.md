%{
  priority: :high,
  status: :outline,
  title: "Getting Started",
  repos: ["agent_jido"],
  tags: [:docs, :getting_started, :navigation, :hub_getting_started, :format_livebook, :wave_1],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/getting-started",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Complete the fastest safe onboarding path",
   "Understand required prerequisites before advanced guides", "Transition into hands-on Learn flows"],
  order: 10,
  prerequisites: ["docs/_hub"],
  purpose: "Consolidate first-step docs paths and reduce new-user confusion",
  related: ["docs/learn/installation", "docs/learn/first-agent", "docs/learn/agent-fundamentals", "ecosystem/overview"],
  source_files: ["marketing/content-outline.md", "marketing/persona-journeys.md"],
  source_modules: ["AgentJido.ContentPlan"],
  prompt_overrides: %{
    document_intent: "Create the single entry point page that a brand new Jido user reads first. Route them into the Learn section.",
    required_sections: ["What is Jido?", "Prerequisites", "Your First Steps"],
    must_include: ["Direct link to /docs/learn/installation as the first action",
     "Brief explanation of what Jido is and what it is not",
     "Estimated time to complete the onboarding ladder (installation → first-agent → first-llm-agent → first-workflow)"],
    must_avoid: ["Duplicating installation steps", "Deep technical detail — this is a routing page"],
    required_links: ["/docs/learn/installation", "/docs/learn/first-agent", "/docs/learn/first-llm-agent",
     "/docs/learn/first-workflow", "/docs/concepts"],
    min_words: 250,
    max_words: 600,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Hub page that groups setup, first agent, and core mental models with explicit next steps.

### Validation Criteria

- Includes expected completion time for each recommended path
- Includes direct links into Learn onboarding ladder
- Avoids duplicating detailed implementation content
