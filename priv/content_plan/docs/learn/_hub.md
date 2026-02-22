%{
  priority: :high,
  status: :planned,
  title: "Learn Hub",
  repos: ["agent_jido"],
  tags: [:docs, :learn, :navigation, :hub_learn, :format_markdown, :wave_1],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/learn",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Understand the onboarding progression from installation to workflows",
   "Navigate training modules and build guides by skill level",
   "Choose the right starting point based on experience"],
  order: 1,
  prerequisites: ["docs/getting-started"],
  purpose: "Section root that routes users through onboarding ladder, training modules, and build guides",
  related: ["docs/learn/installation", "docs/learn/first-agent", "docs/learn/agent-fundamentals",
   "docs/learn/counter-agent"],
  prompt_overrides: %{
    document_intent: "Create the learn section hub that organizes 25 pages into a clear progression.",
    required_sections: ["Onboarding Ladder", "Training Modules", "Build Guides"],
    must_include: ["Visual progression path from installation through first-workflow",
     "Brief description of each sub-group with recommended order"],
    must_avoid: ["Duplicating content from individual pages"],
    required_links: ["/docs/learn/installation", "/docs/learn/first-agent", "/docs/learn/first-llm-agent",
     "/docs/learn/first-workflow", "/docs/learn/agent-fundamentals"],
    min_words: 300,
    max_words: 600,
    minimum_code_blocks: 0,
    diagram_policy: "optional",
    section_density: "minimal",
    max_paragraph_sentences: 2
  }
}
---
## Content Brief

Section root for Learn. Organizes onboarding ladder, training modules, and build guides into a clear progression.

### Validation Criteria

- Shows clear ordering: onboarding → training → build guides
- Each sub-group has a brief description and recommended starting page
- Links to at least one page in each sub-group
