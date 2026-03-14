%{
  title: "Jido.AI Skills Runtime Foundations",
  description: "Real skill manifest loading, registry setup, and prompt rendering with checked-in `SKILL.md` fixtures.",
  tags: ["primary", "showcase", "ai", "l2", "ai-tool-use", "skills", "runtime", "jido_ai"],
  category: :ai,
  emoji: "📚",
  related_resources: [
    %{
      path: "/docs/learn/multi-agent-orchestration",
      kind: "Tutorial",
      description: "Skill-aware orchestration patterns for agents.",
      include_livebook: true
    },
    %{
      type: :external,
      label: "skills runtime foundations demo",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/scripts/demo/skills_runtime_foundations_demo.exs",
      kind: "Source",
      description: "Manifest, registry, and prompt rendering checks."
    },
    %{
      type: :external,
      label: "skills system guide",
      href: "https://github.com/agentjido/jido_ai/blob/main/guides/developer/skills_system.md",
      kind: "Guide",
      description: "Loader, registry, and prompt APIs for file-backed and module-backed skills."
    }
  ],
  source_files: [
    "lib/agent_jido/demos/skills_runtime_foundations/calculator_skill.ex",
    "lib/agent_jido/demos/skills_runtime_foundations/runtime_demo.ex",
    "lib/agent_jido_web/examples/skills_runtime_foundations_live.ex",
    "priv/skills/skills-runtime-foundations/demo-code-review/SKILL.md",
    "priv/skills/skills-runtime-foundations/demo-release-notes/SKILL.md"
  ],
  live_view_module: "AgentJidoWeb.Examples.SkillsRuntimeFoundationsLive",
  difficulty: :intermediate,
  status: :live,
  scenario_cluster: :ai_tool_use,
  wave: :l2,
  journey_stage: :evaluation,
  content_intent: :reference,
  capability_theme: :ai_intelligence,
  evidence_surface: :runnable_example,
  demo_mode: :real,
  sort_order: 23
}
---

## What you'll learn

- How `Jido.AI.Skill.Loader.load/1` parses checked-in `SKILL.md` files into runtime manifests
- How `Jido.AI.Skill.Registry.load_from_paths/1` and `Jido.AI.Skill.Registry.register/1` populate one deterministic registry
- How `Jido.AI.Skill.Prompt.render/2` turns those registered skills into reusable prompt instructions

## How this demo stays truthful

This page runs **real skills runtime code**.

- One skill is defined as an Elixir module with `use Jido.AI.Skill`.
- Two skills are loaded from checked-in `priv/skills/.../SKILL.md` files.
- The demo registers only those three demo skills, renders the combined prompt, and never calls external services.

No API keys, LLM providers, or network access are required for this example.

## Pull the pattern into your own app

Keep the same runtime steps in your own project:

- define stable module-backed skills for core workflows
- add file-backed `SKILL.md` assets when you want editable runtime instructions
- register those skills into the runtime registry
- render the combined prompt text once your agent or workflow needs it
