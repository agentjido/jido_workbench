%{
  priority: :medium,
  status: :outline,
  title: "Manager Adoption Roadmap",
  repos: ["jido"],
  tags: [:docs, :community, :management, :adoption],
  audience: :beginner,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/community/manager-roadmap",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Build an ROI case for Jido adoption",
   "Assess and mitigate risks in adopting a new agent framework",
   "Plan a realistic adoption timeline",
   "Communicate adoption plans to stakeholders effectively"],
  order: 40,
  prerequisites: [],
  purpose: "Non-technical guide for engineering managers covering ROI, risk assessment, adoption timeline, and stakeholder communication for Jido adoption",
  related: ["docs/community/adoption-playbooks", "docs/community/case-studies"],
  legacy_paths: ["/training/manager-roadmap"],
  prompt_overrides: %{
    document_intent: "Write a non-technical adoption roadmap for engineering managers evaluating or championing Jido.",
    required_sections: ["Executive Summary", "ROI Framework", "Risk Assessment",
     "Adoption Timeline", "Stakeholder Communication"],
    must_include: ["ROI framework with concrete dimensions to measure",
     "Common risks and mitigation strategies",
     "Phased adoption timeline with milestones",
     "Templates or talking points for stakeholder conversations"],
    must_avoid: ["Deep technical implementation details — link to technical docs",
     "Jargon-heavy language — this is for managers, not developers"],
    required_links: ["/docs/community/adoption-playbooks", "/docs/community/case-studies"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 0,
    diagram_policy: "optional",
    section_density: "minimal",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Non-technical adoption roadmap for engineering managers. Covers building an ROI case, assessing risks, planning a realistic timeline, and communicating with stakeholders.

### Validation Criteria

- ROI framework includes concrete, measurable dimensions
- Risk assessment covers common adoption risks with mitigation strategies
- Timeline is phased with clear milestones
- Stakeholder communication section includes talking points or templates
- Language is accessible to non-technical managers
