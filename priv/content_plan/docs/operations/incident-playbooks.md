%{
  priority: :high,
  status: :outline,
  title: "Incident Playbooks",
  repos: ["jido"],
  tags: [:docs, :operations, :incidents, :runbooks, :reliability],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/operations/incident-playbooks",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Diagnose and recover from common agent production incidents",
   "Follow structured runbooks for agent crashes, queue buildup, and provider outages",
   "Establish escalation procedures for unresolved agent issues"],
  order: 30,
  prerequisites: ["docs/operations/production-readiness-checklist", "docs/concepts/agent-runtime"],
  purpose: "Runbooks for diagnosing and recovering from common production incidents in Jido agent systems",
  related: ["docs/operations/production-readiness-checklist",
   "docs/guides/retries-backpressure-and-failure-recovery"],
  prompt_overrides: %{
    document_intent: "Write incident playbooks for common production incidents in Jido agent systems.",
    required_sections: ["Agent Crash Recovery", "Queue Buildup", "Provider Outage", "Memory Leaks", "Escalation Procedures"],
    must_include: ["Step-by-step diagnosis commands using Observer and remote shell",
     "AgentServer restart and state recovery procedures",
     "LLM provider failover and circuit breaker activation",
     "BEAM memory analysis for agent process leaks"],
    must_avoid: ["Basic OTP supervision — assume reader knows supervision trees",
     "Initial setup and configuration — that's the production readiness checklist"],
    required_links: ["/docs/operations/production-readiness-checklist",
     "/docs/guides/retries-backpressure-and-failure-recovery"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Runbooks for common production incidents in Jido agent systems. Provides step-by-step diagnosis and recovery procedures for agent crashes, queue buildup, LLM provider outages, and memory leaks.

Cover:
- Agent crash recovery with state restoration
- Queue buildup diagnosis and backpressure activation
- LLM provider outage handling and failover
- Memory leak detection in agent processes
- Escalation procedures for unresolved incidents

### Validation Criteria

- Each playbook follows a consistent diagnose → mitigate → recover structure
- Diagnosis commands are runnable via remote shell or Observer
- Recovery procedures reference current AgentServer and supervision APIs
- Escalation path is clearly defined with decision points
