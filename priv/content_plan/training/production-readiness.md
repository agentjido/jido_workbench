%{
  title: "Production Readiness: Supervision, Telemetry, and Failure Modes",
  order: 60,
  purpose: "Prepare teams to operate Jido agent systems safely under production constraints",
  audience: :advanced,
  content_type: :guide,
  learning_outcomes: [
    "Pick supervision strategies by workload profile",
    "Instrument latency, throughput, and failures with telemetry",
    "Create practical runbooks for common incidents"
  ],
  repos: ["jido", "agent_jido"],
  source_modules: ["AgentJidoWeb.JidoFeaturesLive", "AgentJidoWeb.Telemetry"],
  source_files: ["priv/training/production-readiness.md", "lib/agent_jido_web/live/jido_features_live.ex", "lib/agent_jido_web/telemetry.ex"],
  status: :published,
  priority: :critical,
  prerequisites: ["training/liveview-integration"],
  related: [
    "features/supervision-and-fault-isolation",
    "features/production-telemetry",
    "operate/retries-backpressure-and-failure-recovery",
    "operate/troubleshooting-and-debugging-playbook",
    "operate/production-readiness-checklist",
    "reference/telemetry-and-observability"
  ],
  ecosystem_packages: ["jido", "agent_jido"],
  tags: [:training, :production, :telemetry, :supervision]
}
---
## Content Brief

Advanced module focusing on resilience, observability, and pre-launch operational controls.

### Validation Criteria

- Covers supervision strategy and fault containment
- Covers telemetry dimensions for alerting and diagnosis
- Includes actionable readiness checklist handoff to Operate
