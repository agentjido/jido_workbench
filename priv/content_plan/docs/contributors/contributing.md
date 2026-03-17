%{
  priority: :high,
  status: :outline,
  title: "Contributing Guide",
  repos: ["agent_jido"],
  tags: [:docs, :contributors, :contributing],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/contributors/contributing",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Find the right contribution lane",
   "Understand how to start small and how stewardship works"],
  order: 5,
  prerequisites: [],
  purpose: "Contributor-facing guide for entering Jido contribution work across code, docs, testing, and stewardship",
  related: ["docs/contributors/package-quality-standards", "docs/contributors/governance-and-team",
   "docs/community/_hub"],
  prompt_overrides: %{
    document_intent: "Write the contributing page as a lightweight guide to participation and flow.",
    required_sections: ["Contribution Lanes", "Lightweight Contribution Flow", "How to Start Small"],
    must_include: ["Code, docs, examples, testing, and community contribution lanes",
     "Explanation that package stewardship is a contribution path"],
    must_avoid: ["Heavy process language", "Community CTA duplication that belongs on `/community`"],
    required_links: ["/community", "/docs/contributors/package-quality-standards",
     "/docs/contributors/governance-and-team"],
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

Contributor-facing guide for how people join and work in the ecosystem.

### Validation Criteria

- Makes it clear contributors can start small
- Covers package stewardship as a lightweight path
- Links to `/community` for social entry rather than duplicating it
