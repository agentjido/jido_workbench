%{
  title: "LiveView and Jido Integration Patterns",
  order: 50,
  purpose: "Show how to connect LiveView events and rendering to immutable Jido state transitions",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Map UI intent to explicit agent commands",
    "Render deterministic UI state from command outputs",
    "Expose directive outcomes transparently in product UX"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["Phoenix.LiveView", "AgentJidoWeb.JidoTrainingModuleLive"],
  source_files: ["priv/training/liveview-integration.md", "lib/agent_jido_web/live/jido_training_live.ex", "lib/agent_jido_web/live/jido_training_module_live.ex"],
  status: :published,
  priority: :high,
  prerequisites: ["training/directives-scheduling"],
  related: ["training/production-readiness", "features/liveview-integration-patterns", "build/counter-agent", "docs/testing-agents-and-actions"],
  ecosystem_packages: ["agent_jido", "jido"],
  destination_route: "/training/liveview-integration",
  destination_collection: :training,
  tags: [:training, :liveview, :integration, :ui]
}
---
## Content Brief

Hands-on module for deterministic UI integration with command-driven runtime behavior.

### Validation Criteria

- Includes event-to-command-to-render flow examples
- Includes next-step links to production readiness and testing
- Aligns with module-card and curriculum navigation behavior
