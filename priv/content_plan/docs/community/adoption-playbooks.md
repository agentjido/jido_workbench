%{
  priority: :medium,
  status: :outline,
  title: "Adoption Playbooks",
  repos: ["jido"],
  tags: [:docs, :community, :adoption],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/community/adoption-playbooks",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Select a suitable pilot project for Jido adoption",
   "Plan a team onboarding process for Jido",
   "Define success metrics for Jido adoption",
   "Scale adoption from pilot to broader engineering organization"],
  order: 10,
  prerequisites: [],
  purpose: "Provide actionable playbooks for teams adopting Jido — pilot project selection, team onboarding, success metrics, and scaling strategies",
  related: ["docs/community/manager-roadmap", "docs/community/learning-paths"],
  legacy_paths: ["/community/adoption-playbooks"],
  prompt_overrides: %{
    document_intent: "Write practical adoption playbooks that help engineering teams introduce and scale Jido.",
    required_sections: ["Pilot Project Selection", "Team Onboarding", "Success Metrics", "Scaling Adoption"],
    must_include: ["Criteria for choosing a good pilot project",
     "Step-by-step team onboarding checklist",
     "Measurable success metrics for adoption",
     "Strategies for scaling from pilot to organization-wide use"],
    must_avoid: ["Deep technical implementation details — link to guides and learn sections",
     "Vendor-comparison language or competitive positioning"],
    required_links: ["/docs/community/manager-roadmap", "/docs/community/learning-paths"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 1,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Actionable playbooks for teams adopting Jido. Covers pilot project selection, team onboarding, success metrics, and scaling adoption across an engineering organization.

### Validation Criteria

- Pilot selection criteria are concrete and actionable
- Onboarding section includes a checklist or step-by-step process
- Success metrics are measurable and time-bound
- Scaling strategies address common organizational challenges
