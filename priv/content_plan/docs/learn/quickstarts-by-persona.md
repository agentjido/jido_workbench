%{
  priority: :high,
  status: :outline,
  title: "Quickstarts by Persona",
  repos: ["agent_jido"],
  tags: [:docs, :learn, :persona, :quickstart, :journeys, :wave_1],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/learn/quickstarts-by-persona",
  legacy_paths: ["/build/quickstarts-by-persona"],
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Pick the right quickstart path for your role and stack",
   "Complete a bounded first milestone in under one session",
   "Know the next Learn, Concepts, and Operations steps"],
  order: 31,
  prerequisites: ["docs/learn/installation"],
  purpose: "Provide role-specific starting paths so each persona can reach first value quickly",
  related: ["docs/learn/installation", "docs/learn/first-agent",
   "docs/learn/agent-fundamentals", "docs/operations/production-readiness-checklist"],
  source_files: ["marketing/persona-journeys.md", "marketing/content-outline.md"],
  source_modules: ["AgentJido.ContentPlan"],
  prompt_overrides: %{
    document_intent: "Create persona-specific quickstart paths for five target audiences.",
    required_sections: ["Choose Your Path", "Elixir Platform Engineer", "AI Product Engineer",
     "Python AI Engineer", "TypeScript Fullstack Engineer", "Platform/SRE Engineer"],
    must_include: ["Each persona path has a concrete first action and expected outcome",
     "Each path links to exactly one next step in Learn and one in Operations/Reference"],
    must_avoid: ["Duplicating installation steps", "Making any persona feel unwelcome"],
    required_links: ["/docs/learn/installation", "/docs/learn/first-agent", "/docs/learn/agent-fundamentals"],
    min_words: 400,
    max_words: 800,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Persona router page for Elixir platform engineer, AI product engineer, Python AI engineer, TypeScript fullstack engineer, and Platform/SRE engineer.

### Validation Criteria

- Each persona path has a concrete first action and expected outcome
- Each path links to exactly one next step in Learn and one in Operations/Reference
- Aligns with canonical journeys in marketing/persona-journeys.md
