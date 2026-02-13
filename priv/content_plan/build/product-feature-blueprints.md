%{
  title: "Product Feature Blueprints",
  order: 110,
  purpose: "Translate common product requirements into implementation blueprints that combine Build, Training, and Operate assets",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Map user-facing AI requirements to architecture components",
    "Use reusable blueprint templates for delivery planning",
    "Attach readiness criteria before launch"
  ],
  repos: ["agent_jido", "jido", "jido_ai"],
  source_modules: ["AgentJido.ContentPlan", "Jido.Agent"],
  source_files: [
    "marketing/content-outline.md",
    "marketing/persona-journeys.md",
    "priv/content_plan/**/*.md"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["build/counter-agent", "ecosystem/package-selection-by-use-case"],
  related: [
    "build/ai-chat-agent",
    "build/multi-agent-workflows",
    "docs/production-readiness-checklist",
    "training/production-readiness"
  ],
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai", "agent_jido"],
  destination_route: "/build/product-feature-blueprints",
  destination_collection: :pages,
  tags: [:build, :blueprints, :product, :delivery]
}
---
## Content Brief

Reusable templates for common features like conversational agents, background orchestration, and tool-driven assistants.

### Validation Criteria

- Each blueprint includes architecture, test strategy, and readiness checklist
- Each blueprint links to one runnable example and one operate runbook
- Includes explicit non-goals to prevent over-scoping initial delivery
