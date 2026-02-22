%{
  priority: :critical,
  status: :outline,
  title: "Production Readiness Checklist",
  repos: ["jido", "jido_otel"],
  tags: [:docs, :operations, :production, :checklist, :deployment],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/operations/production-readiness-checklist",
  ecosystem_packages: ["jido", "jido_otel"],
  learning_outcomes: ["Validate agent systems are production-ready before deployment",
   "Configure runtime settings for production environments",
   "Set up monitoring and alerting for agent health"],
  order: 10,
  prerequisites: ["docs/concepts/agent-runtime", "docs/learn/production-readiness"],
  purpose: "Comprehensive checklist for deploying Jido agents to production with confidence",
  related: ["docs/learn/production-readiness", "docs/operations/security-and-governance",
   "docs/guides/retries-backpressure-and-failure-recovery"],
  prompt_overrides: %{
    document_intent: "Write a production readiness checklist for deploying Jido agents to production environments.",
    required_sections: ["Pre-Deploy Checks", "Runtime Configuration", "Monitoring Setup", "Scaling Considerations"],
    must_include: ["OTP release configuration essentials",
     "OpenTelemetry tracing setup with jido_otel",
     "Health check endpoint configuration",
     "Agent pool sizing and resource limits"],
    must_avoid: ["Basic agent concepts — assume reader knows fundamentals",
     "Security details — that's covered in the security guide"],
    required_links: ["/docs/learn/production-readiness", "/docs/operations/security-and-governance",
     "/docs/guides/retries-backpressure-and-failure-recovery"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Comprehensive checklist for deploying Jido agents to production. Covers pre-deploy validation, runtime configuration, monitoring setup, and scaling considerations.

Cover:
- Pre-deploy checks for OTP release readiness
- Runtime configuration for production environments
- OpenTelemetry tracing and monitoring setup with jido_otel
- Agent pool sizing and scaling considerations

### Validation Criteria

- Checklist items are actionable and verifiable
- Configuration examples use current Jido and jido_otel APIs
- Monitoring setup covers both infrastructure and agent-level health
- Links to security guide for complementary operational concerns
