%{
  priority: :high,
  status: :outline,
  title: "Package Support Levels",
  repos: ["agent_jido"],
  tags: [:docs, :contributors, :support, :taxonomy],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/contributors/package-support-levels",
  ecosystem_packages: ["jido", "jido_ai", "req_llm"],
  learning_outcomes: ["Understand the meaning of Stable, Beta, and Experimental",
   "Avoid confusing support labels with roadmap priority or release state"],
  order: 3,
  prerequisites: [],
  purpose: "Canonical support taxonomy for public Jido packages",
  related: ["docs/contributors/ecosystem-atlas", "docs/contributors/roadmap"],
  prompt_overrides: %{
    document_intent: "Write the package support levels page as a tight policy reference.",
    required_sections: ["Support Levels", "What This Label Is And Is Not", "When To Use Each Label"],
    must_include: ["Clarification that support level is not packaging status",
     "Clarification that support level is not roadmap priority"],
    must_avoid: ["Package-by-package roster detail"],
    required_links: ["/docs/contributors/ecosystem-atlas", "/docs/contributors/roadmap"],
    min_words: 300,
    max_words: 800,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Canonical support taxonomy for public Jido packages.

### Validation Criteria

- Keeps definitions separate from package assignments
- Explains how contributors should choose a support label
- Distinguishes support commitment from release state and roadmap sequencing
