%{
  priority: :medium,
  status: :planned,
  title: "Case Studies",
  repos: ["jido"],
  tags: [:docs, :community, :case_studies],
  audience: :beginner,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/community/case-studies",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Understand how real teams have adopted Jido",
   "Identify patterns in successful Jido deployments",
   "Apply lessons from case studies to own adoption context"],
  order: 20,
  prerequisites: [],
  purpose: "Showcase real-world Jido adoption stories — problem, approach, and results — to help teams evaluate fit",
  related: ["docs/community/adoption-playbooks"],
  legacy_paths: ["/community/case-studies"],
  prompt_overrides: %{
    document_intent: "Present real-world case studies of Jido adoption with a consistent problem-approach-results format.",
    required_sections: ["Overview", "Case Study Template", "Featured Case Studies"],
    must_include: ["Consistent structure: problem, approach, results for each case study",
     "Quantifiable results where possible",
     "Variety of use cases and team sizes"],
    must_avoid: ["Fabricated or unverifiable claims",
     "Marketing hyperbole — let results speak"],
    required_links: ["/docs/community/adoption-playbooks"],
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

Real-world case studies of Jido adoption. Each case study follows a consistent problem-approach-results format to help teams evaluate fit for their own context.

### Validation Criteria

- Each case study follows the problem → approach → results template
- Results include measurable outcomes where available
- Case studies represent a variety of use cases and team sizes
- Links to adoption playbooks for readers ready to start their own journey
