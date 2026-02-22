%{
  priority: :high,
  status: :published,
  title: "Production Readiness",
  repos: ["jido", "agent_jido"],
  tags: [:docs, :learn, :training, :production, :supervision, :telemetry],
  audience: :advanced,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/production-readiness",
  legacy_paths: ["/training/production-readiness"],
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Choose supervision strategies aligned with agent workload patterns",
   "Instrument agent paths with actionable telemetry events",
   "Design recovery playbooks for common failure modes"],
  order: 25,
  prerequisites: ["docs/learn/liveview-integration"],
  purpose: "Teach how to harden agent workloads for production with supervision, telemetry, and controlled failure recovery",
  related: ["docs/operations/production-readiness-checklist",
   "docs/reference/telemetry-and-observability",
   "docs/guides/retries-backpressure-and-failure-recovery"],
  source_files: ["lib/jido/agent_server.ex"],
  source_modules: ["Jido.AgentServer"],
  prompt_overrides: %{
    document_intent: "Write the capstone training module on hardening agent workloads — supervision, telemetry, failure modes, and runbooks.",
    required_sections: ["Supervision Strategy", "Back-Pressure Controls", "Telemetry Design", "Failure Modes", "Runbooks", "Hands-on Exercise"],
    must_include: ["Map agent classes to restart policies",
     "Monitor queue depth and command latency",
     "Emit telemetry with stable dimensions and cardinality limits",
     "Dependency outage, malformed signal burst, and hot loop failure scenarios",
     "Production-readiness checklist exercise with outage drill"],
    must_avoid: ["Repeating basic agent concepts from earlier modules", "Vendor-specific monitoring tool setup"],
    required_links: ["/docs/operations/production-readiness-checklist",
     "/docs/reference/telemetry-and-observability",
     "/docs/learn/liveview-integration"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "recommended",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Capstone training module on hardening agent workloads for production: supervision strategy, telemetry instrumentation, failure mode analysis, and operational runbooks.

Cover:
- Supervision strategy selection by workload type
- Back-pressure monitoring for queue depth and latency
- Telemetry design with stable dimensions
- Failure mode analysis: outages, signal floods, hot loops
- Production-readiness checklist exercise

### Validation Criteria

- Supervision patterns align with `Jido.AgentServer` implementation
- Telemetry examples use `:telemetry` conventions from the codebase
- Exercise includes at least one simulated failure drill
- Links to operations checklist and telemetry reference for deeper detail
