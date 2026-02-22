%{
  priority: :critical,
  status: :draft,
  title: "Actions",
  repos: ["jido", "jido_action"],
  tags: [:docs, :concepts, :core, :actions],
  audience: :beginner,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/concepts/actions",
  ecosystem_packages: ["jido", "jido_action"],
  learning_outcomes: ["Define actions as pure state transition functions with schema-validated inputs",
   "Understand action composition and the Plan model",
   "Know the return contract: state deltas and directives"],
  order: 30,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Document the Jido action primitive — schema-validated pure functions that produce state transitions and directives",
  related: ["docs/concepts/agents", "docs/concepts/directives",
   "docs/learn/actions-validation", "docs/learn/first-workflow"],
  source_files: ["lib/jido/action.ex", "lib/jido/plan.ex", "lib/jido/instruction.ex"],
  source_modules: ["Jido.Action", "Jido.Plan", "Jido.Instruction"],
  prompt_overrides: %{
    document_intent: "Write the authoritative concept page for Jido Actions — pure state transition functions with validated inputs.",
    required_sections: ["What Is an Action?", "Input Schema and Validation", "Return Contract", "Action Composition", "Plans and Instructions"],
    must_include: ["Actions as modules with `use Jido.Action`",
     "Schema-validated input parameters with defaults",
     "Return tuples: `{:ok, state_delta}` and `{:error, reason}`",
     "Composition via Plans for multi-step workflows",
     "Relationship between actions and directives"],
    must_avoid: ["Tutorial-style walkthroughs — link to Learn section",
     "Signal routing details — that's the signals page"],
    required_links: ["/docs/concepts/agents", "/docs/concepts/directives",
     "/docs/learn/actions-validation", "/docs/learn/first-workflow"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Authoritative concept page for Jido Actions — schema-validated pure functions that produce state transitions and directives.

Cover:
- Action definition with `use Jido.Action`
- Input schema validation and defaults
- Return contract: state deltas and error tuples
- Composition via Plans and Instructions

### Validation Criteria

- Action definition aligns with `Jido.Action` source module
- Return contract matches actual API behavior
- Plan composition accurately describes multi-action orchestration
- Links to learn/actions-validation for hands-on practice
