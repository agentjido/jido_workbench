%{
  priority: :critical,
  status: :outline,
  title: "Security and Governance",
  repos: ["jido", "jido_ai"],
  tags: [:docs, :operations, :security, :governance, :compliance],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/operations/security-and-governance",
  ecosystem_packages: ["jido", "jido_ai"],
  learning_outcomes: ["Implement access control patterns for agent actions",
   "Configure audit logging for agent operations",
   "Apply LLM prompt safety and data handling best practices"],
  order: 20,
  prerequisites: ["docs/concepts/agent-runtime", "docs/operations/production-readiness-checklist"],
  purpose: "Guide for securing Jido agent systems with access control, audit logging, prompt safety, and data handling patterns",
  related: ["docs/operations/production-readiness-checklist",
   "docs/guides/retries-backpressure-and-failure-recovery"],
  prompt_overrides: %{
    document_intent: "Write a security and governance guide for Jido agent systems covering access control, audit logging, and LLM safety.",
    required_sections: ["Access Control", "Audit Logging", "Prompt Safety", "Data Handling", "Compliance Considerations"],
    must_include: ["Action-level authorization patterns",
     "Structured audit log format for agent operations",
     "Prompt injection mitigation strategies for jido_ai",
     "Sensitive data redaction in agent state and logs"],
    must_avoid: ["Basic Elixir security — assume reader knows OTP fundamentals",
     "Deployment infrastructure — that's the production readiness checklist"],
    required_links: ["/docs/operations/production-readiness-checklist"],
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

Security and governance guide for Jido agent systems. Covers access control patterns, audit logging, LLM prompt safety, and data handling best practices.

Cover:
- Access control patterns for agent actions and resources
- Structured audit logging for agent operations
- Prompt injection mitigation and LLM safety with jido_ai
- Sensitive data redaction and compliance considerations

### Validation Criteria

- Security patterns are implementable with current Jido and jido_ai APIs
- Audit logging format is structured and machine-parseable
- Prompt safety guidance addresses real-world LLM attack vectors
- Data handling covers both agent state and log output
