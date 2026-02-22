%{
  priority: :medium,
  status: :outline,
  title: "Mixed-Stack Runbooks",
  repos: ["jido"],
  tags: [:docs, :guides, :operations, :mixed_stack, :runbooks],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/mixed-stack-runbooks",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Operate polyglot agent systems with structured runbook procedures",
   "Diagnose cross-language boundary failures",
   "Execute rollback and recovery across Elixir and external services"],
  order: 70,
  prerequisites: ["docs/learn/mixed-stack-integration"],
  purpose: "Provide operational runbooks for polyglot environments where Jido orchestrates across language boundaries",
  related: ["docs/learn/mixed-stack-integration", "docs/operations/incident-playbooks",
   "docs/operations/production-readiness-checklist"],
  prompt_overrides: %{
    document_intent: "Write operational runbooks for polyglot Jido environments — cross-boundary diagnostics, rollback, and recovery.",
    required_sections: ["Runbook Format", "Cross-Boundary Health Checks", "Boundary Failure Diagnosis", "Rollback Procedures", "Recovery Verification"],
    must_include: ["Structured runbook format with trigger, steps, verification",
     "Health check patterns across language boundaries",
     "Common cross-boundary failure modes and diagnosis",
     "Rollback procedures for partial deployments"],
    must_avoid: ["Mixed-stack architecture design — that's the learn tutorial",
     "Single-language operational procedures"],
    required_links: ["/docs/learn/mixed-stack-integration",
     "/docs/operations/incident-playbooks"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Operational runbooks for polyglot environments where Jido orchestrates across Elixir and external language services.

Cover:
- Structured runbook format
- Cross-boundary health checks
- Failure diagnosis at language boundaries
- Rollback and recovery procedures

### Validation Criteria

- Runbook format is consistent and actionable
- Cross-boundary failures are diagnosed with concrete steps
- Rollback covers partial deployment scenarios
- Links to mixed-stack-integration for architecture context
