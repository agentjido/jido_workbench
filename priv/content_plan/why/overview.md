%{
  title: "Why Jido",
  order: 1,
  purpose: "Establish the runtime-first thesis and define when Jido is the right fit for production multi-agent systems",
  audience: :beginner,
  content_type: :explanation,
  learning_outcomes: [
    "Explain Jido as a runtime for reliable multi-agent systems",
    "Identify the operational gap between prototype speed and production reliability",
    "Choose the next evaluation path based on persona and stack context"
  ],
  repos: ["agent_jido", "jido"],
  source_modules: ["AgentJidoWeb.JidoHomeLive", "AgentJido.Ecosystem"],
  source_files: [
    "marketing/positioning.md",
    "marketing/content-outline.md",
    "marketing/persona-journeys.md",
    "lib/agent_jido_web/live/jido_home_live.ex",
    "lib/agent_jido/ecosystem.ex"
  ],
  status: :outline,
  priority: :critical,
  prerequisites: [],
  related: [
    "why/beam-for-ai-builders",
    "why/jido-vs-framework-first-stacks",
    "features/beam-native-agent-model",
    "ecosystem/package-matrix",
    "build/quickstarts-by-persona"
  ],
  ecosystem_packages: ["jido", "jido_action", "jido_signal", "jido_ai", "agent_jido"],
  tags: [:why, :positioning, :runtime, :navigation]
}
---
## Content Brief

Primary narrative page for the `Why -> Features -> Ecosystem -> Build` journey.

Cover:

- The anchor phrase: Jido is a runtime for reliable, multi-agent systems
- Why runtime architecture matters once workflows move beyond demos
- What Jido is and is not (not just prompt orchestration)
- Persona-based next steps to Features, Ecosystem, and Build

### Validation Criteria

- Includes explicit link-out CTAs for Elixir-native, mixed-stack, and leadership audiences
- Claims are tied to at least one concrete proof surface in Features and one in Training/Operate
- Uses outcome-first language before introducing BEAM terminology
