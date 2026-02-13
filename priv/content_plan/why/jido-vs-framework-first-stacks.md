%{
  title: "Jido vs Framework-First Stacks",
  order: 3,
  purpose: "Provide fit-for-purpose differentiation for teams comparing Jido to prototype-first agent frameworks",
  audience: :intermediate,
  content_type: :explanation,
  learning_outcomes: [
    "Compare runtime model tradeoffs without hype",
    "Determine when prototype-first tools are sufficient",
    "Determine when runtime-first architecture is required"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.Agent", "Jido.AgentServer", "AgentJidoWeb.JidoFeaturesLive"],
  source_files: [
    "marketing/positioning.md",
    "marketing/content-outline.md",
    "lib/agent_jido_web/live/jido_features_live.ex"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["why/overview"],
  related: [
    "why/executive-brief",
    "features/supervision-and-fault-isolation",
    "operate/production-readiness-checklist",
    "reference/telemetry-and-observability"
  ],
  ecosystem_packages: ["jido", "jido_signal", "jido_action", "agent_jido"],
  tags: [:why, :comparison, :runtime, :reliability]
}
---
## Content Brief

Respectful comparison page focused on optimization target differences.

Cover:

- Prototype-first vs runtime-first optimization priorities
- Failure containment, observability posture, and lifecycle governance differences
- Evaluation checklist to choose the right tool for each phase
- Links into concrete build and operations proof

### Validation Criteria

- Uses fit-for-purpose framing, not attack language
- Every major comparison row links to at least one Jido proof page
- Includes explicit statement of where prototype-first tools are a good fit
