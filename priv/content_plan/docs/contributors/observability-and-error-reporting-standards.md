%{
  priority: :critical,
  status: :outline,
  title: "Observability and Error Reporting Standards",
  repos: ["jido_action", "jido_signal", "jido_ai", "agent_jido"],
  tags: [:docs, :contributors, :observability, :errors, :policy],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/contributors/observability-and-error-reporting-standards",
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai"],
  learning_outcomes: ["Audit a package's logging, telemetry, and error handling against the shared Jido baseline",
   "Implement a canonical package boundary for normalization, sanitization, and public error serialization",
   "Distinguish what belongs in logs, telemetry, and public error contracts"],
  order: 11,
  prerequisites: ["docs/contributors/_hub", "docs/reference/telemetry-and-observability"],
  purpose: "Canonical contributor-facing implementation guide for logging, telemetry, sanitization, and Splode-backed error contracts across the Jido ecosystem",
  related: ["docs/contributors/package-quality-standards", "docs/reference/telemetry-and-observability",
   "docs/contributors/contributing", "docs/guides/testing-agents-and-actions"],
  prompt_overrides: %{
    document_intent: "Create the canonical contributor standards page for Jido observability and error reporting policy.",
    required_sections: ["Fast Path Checklist", "How to use this page", "Core Principles",
     "What Goes Where", "Canonical Responsibility Split", "Minimum Package Surface",
     "Logging Standards", "Telemetry Standards", "Sanitization Standards",
     "Splode Error Standards", "Boundary Pattern", "Verification Expectations",
     "Review Checklist", "Anti-Patterns"],
    must_include: ["Clear separation between logs, telemetry, and public error contracts",
     "Direct `Logger` policy and lazy logging guidance",
     "Two-profile sanitization guidance for `:telemetry` and `:transport`",
     "Stable `Error.to_map/1` policy",
     "At least one bounded boundary example showing normalize -> observe -> transport flow"],
    must_avoid: ["Runtime-specific event inventories that belong on the telemetry reference page",
     "Package-specific implementation detail that should live in per-repo docs"],
    required_links: ["/docs/contributors", "/docs/contributors/package-quality-standards",
     "/docs/reference/telemetry-and-observability", "/docs/contributors/contributing"],
    min_words: 1200,
    max_words: 2600,
    minimum_code_blocks: 4,
    diagram_policy: "none",
    section_density: "standard",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Canonical implementation guide for logging, telemetry, sanitization, and error reporting across public Jido packages.

### Validation Criteria

- Includes a fast review path near the top
- Separates human logs, machine telemetry, and public error contracts clearly
- Defines the minimum canonical package surfaces for errors, sanitization, and observation
- Includes actionable examples for telemetry spans and `Error.to_map/1`
- States verification expectations clearly enough to link from reviews and implementation handoffs
