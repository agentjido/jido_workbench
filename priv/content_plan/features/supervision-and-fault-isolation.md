%{
  title: "Supervision and Fault Isolation",
  order: 70,
  purpose: "Represent runtime resilience features rooted in OTP supervision and failure containment",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Explain supervision strategy tradeoffs for agent systems",
    "Relate fault isolation to incident reduction",
    "Connect containment patterns to runbook design"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["Jido.AgentServer", "AgentJidoWeb.JidoFeaturesLive"],
  source_files: ["lib/agent_jido_web/live/jido_features_live.ex", "priv/training/production-readiness.md", "lib/jido/agent_server.ex"],
  status: :published,
  priority: :critical,
  prerequisites: ["features/directives-and-scheduling"],
  related: ["training/production-readiness", "operate/production-readiness-checklist", "operate/incident-playbooks"],
  ecosystem_packages: ["jido", "agent_jido"],
  tags: [:features, :supervision, :reliability, :production]
}
---
## Content Brief

Feature entry for resilience messaging around supervision trees and fault boundaries.
