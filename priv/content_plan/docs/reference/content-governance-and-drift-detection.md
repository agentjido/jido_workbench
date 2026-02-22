%{
  priority: :medium,
  status: :outline,
  title: "Content Governance and Drift Detection",
  repos: ["agent_jido"],
  tags: [:docs, :reference, :governance, :drift_detection, :content_review],
  audience: :advanced,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/content-governance-and-drift-detection",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Understand the documentation governance model and review cadence",
   "Set up drift detection between source code and documentation",
   "Automate content review processes"],
  order: 100,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Meta-documentation: how to keep docs accurate, drift detection between code and docs, content review processes",
  related: ["docs/reference/migrations-and-upgrade-paths"],
  prompt_overrides: %{
    document_intent: "Write the content governance reference covering drift detection, review processes, and documentation automation.",
    required_sections: ["Governance Model", "Drift Detection", "Review Process", "Automation"],
    must_include: ["Documentation ownership and review cadence",
     "Drift detection: how to identify when docs fall out of sync with code",
     "Review process workflow and approval gates",
     "Automation tools and CI integration for doc validation"],
    must_avoid: ["Generic technical writing advice — focus on Jido-specific processes",
     "Aspirational processes not yet implemented — document current state"],
    required_links: ["/docs/reference/migrations-and-upgrade-paths"],
    min_words: 400,
    max_words: 800,
    minimum_code_blocks: 1,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Meta-documentation for Jido — content governance model, drift detection between code and docs, review processes, and automation.

Cover:
- Governance model: documentation ownership and review cadence
- Drift detection: identifying when docs fall out of sync with source code
- Review process workflow and approval gates
- Automation tools and CI integration for doc validation

### Validation Criteria

- Governance model defines clear ownership and review cadence
- Drift detection approach is concrete and implementable
- Review process includes specific workflow steps
- Automation section references actual or planned CI tooling
