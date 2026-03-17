%{
  priority: :medium,
  status: :outline,
  title: "Contributors Roadmap",
  repos: ["agent_jido"],
  tags: [:docs, :contributors, :roadmap],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/contributors/roadmap",
  ecosystem_packages: ["jido", "jido_chat", "jido_harness"],
  learning_outcomes: ["Understand the current milestone and next milestone",
   "See how roadmap timing differs from support commitment"],
  order: 4,
  prerequisites: [],
  purpose: "Contributor-facing roadmap page translating milestone and epic planning into a compact public guide",
  related: ["docs/contributors/package-support-levels", "docs/contributors/ecosystem-atlas"],
  prompt_overrides: %{
    document_intent: "Write a concise contributor-facing roadmap page from the current milestone planning.",
    required_sections: ["Major Milestones", "Current Milestone", "Next Milestone", "Active Epics"],
    must_include: ["Current milestone, next milestone, and active epics",
     "Clarification that roadmap timing differs from support level"],
    must_avoid: ["Backlog-level detail", "Long historical narrative"],
    required_links: ["/docs/contributors/package-support-levels", "/docs/contributors/ecosystem-atlas"],
    min_words: 350,
    max_words: 900,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Contributor-facing roadmap for the public Jido ecosystem.

### Validation Criteria

- Preserves milestone names and leads from source planning
- Keeps the page directional rather than backlog-like
- Explains how roadmap relates to the atlas and support levels
