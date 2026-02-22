%{
  priority: :medium,
  status: :outline,
  title: "Learning Paths",
  repos: ["jido"],
  tags: [:docs, :community, :learning_paths],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/community/learning-paths",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Identify the learning path that matches your role",
   "Follow a curated sequence of docs and tutorials for your skill level",
   "Track progress through a structured Jido learning journey"],
  order: 30,
  prerequisites: [],
  purpose: "Curated learning paths by role — backend dev, full-stack dev, team lead, AI/ML engineer — each mapping to existing docs and tutorials",
  related: ["docs/learn/_hub", "docs/community/adoption-playbooks"],
  legacy_paths: ["/community/learning-paths"],
  prompt_overrides: %{
    document_intent: "Create role-based learning paths that guide readers through Jido documentation in an optimal sequence.",
    required_sections: ["How to Use Learning Paths", "Backend Developer Path",
     "Full-Stack Developer Path", "Team Lead Path", "AI/ML Engineer Path"],
    must_include: ["Clear role descriptions so readers self-select the right path",
     "Ordered list of docs and tutorials for each path",
     "Estimated time commitment per path"],
    must_avoid: ["Duplicating tutorial content — link to existing learn and guide pages",
     "Overly prescriptive tone — paths are recommendations, not requirements"],
    required_links: ["/docs/learn", "/docs/community/adoption-playbooks"],
    min_words: 400,
    max_words: 800,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Curated learning paths organized by role. Each path maps a sequence of existing docs and tutorials tailored to backend developers, full-stack developers, team leads, and AI/ML engineers.

### Validation Criteria

- Each role path has a clear description and ordered reading list
- Paths link to existing learn and guide pages rather than duplicating content
- Estimated time commitment is included for each path
- Readers can self-select the correct path based on role descriptions
