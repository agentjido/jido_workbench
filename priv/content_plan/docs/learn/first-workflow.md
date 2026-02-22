%{
  priority: :critical,
  status: :planned,
  title: "Build Your First Workflow",
  repos: ["jido", "jido_action"],
  tags: [:docs, :learn, :tutorial, :workflows, :wave_1],
  audience: :beginner,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/first-workflow",
  ecosystem_packages: ["jido", "jido_action"],
  learning_outcomes: ["Compose multiple actions into a single command",
   "Use Plans to define execution order and dependencies",
   "Handle directive output from multi-step workflows"],
  order: 13,
  prerequisites: ["docs/learn/first-llm-agent"],
  purpose: "Third onboarding tutorial — teach action composition and workflow patterns",
  related: ["docs/learn/counter-agent", "docs/learn/demand-tracker-agent",
   "docs/concepts/actions", "docs/concepts/directives"],
  source_files: ["lib/jido/plan.ex", "lib/jido/instruction.ex", "lib/jido/action.ex"],
  source_modules: ["Jido.Plan", "Jido.Instruction", "Jido.Action"],
  prompt_overrides: %{
    document_intent: "Write the third onboarding tutorial — compose actions into multi-step workflows.",
    required_sections: ["Why Compose Actions?", "Create Multiple Actions", "Build a Plan", "Execute the Workflow", "Handle Directives"],
    must_include: ["Show how to pass multiple actions to cmd/2",
     "Introduce Jido.Plan for DAG-based composition",
     "Demonstrate sequential and parallel step execution",
     "Explain how directive output accumulates from multi-action commands"],
    must_avoid: ["LLM-specific workflows", "Production deployment patterns"],
    required_links: ["/docs/learn/first-agent", "/docs/concepts/actions",
     "/docs/concepts/directives", "/docs/learn/counter-agent"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 4,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Third onboarding tutorial — compose actions into multi-step workflows.

Cover:
- Composing multiple actions into a single cmd/2 call
- Using Jido.Plan for DAG-based workflow composition
- Sequential and parallel step execution
- Directive accumulation from multi-action commands

### Validation Criteria

- Code compiles against current Jido.Plan and Jido.Instruction APIs
- Workflow patterns match source implementation behavior
- Links forward to build examples and concept deep-dives
