%{
  priority: :medium,
  status: :planned,
  title: "Community Hub",
  repos: ["jido"],
  tags: [:docs, :community, :navigation, :hub],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/community",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Navigate community adoption-enablement resources",
   "Identify the right resource based on role and adoption stage"],
  order: 1,
  prerequisites: [],
  purpose: "Section root organizing adoption enablement resources — playbooks, case studies, learning paths, and manager guidance",
  related: ["docs/community/adoption-playbooks", "docs/community/case-studies",
   "docs/community/learning-paths", "docs/community/manager-roadmap"],
  prompt_overrides: %{
    document_intent: "Create the community section hub that orients readers across adoption-enablement resources.",
    required_sections: ["Overview", "Resources"],
    must_include: ["One-line description of each community page",
     "Clear navigation to playbooks, case studies, learning paths, and manager roadmap"],
    must_avoid: ["Duplicating content from individual community pages", "Long prose — this is a navigation page"],
    required_links: ["/docs/community/adoption-playbooks", "/docs/community/case-studies",
     "/docs/community/learning-paths", "/docs/community/manager-roadmap"],
    min_words: 200,
    max_words: 500,
    minimum_code_blocks: 0,
    diagram_policy: "none",
    section_density: "minimal",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Section root for Community. Organizes adoption-enablement resources for teams evaluating or rolling out Jido.

### Validation Criteria

- Each community page has a one-line description and link
- Covers all four sub-pages: adoption playbooks, case studies, learning paths, manager roadmap
- No technical prerequisites assumed
