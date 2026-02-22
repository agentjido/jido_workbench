%{
  priority: :high,
  status: :published,
  title: "Actions and Schema Validation",
  repos: ["jido", "jido_action"],
  tags: [:docs, :learn, :training, :actions, :validation],
  audience: :beginner,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/actions-validation",
  legacy_paths: ["/training/actions-validation"],
  ecosystem_packages: ["jido", "jido_action"],
  learning_outcomes: ["Create actions with explicit parameter contracts",
   "Fail fast on invalid input before state mutation",
   "Return actionable validation errors to upstream callers"],
  order: 21,
  prerequisites: ["docs/learn/agent-fundamentals"],
  purpose: "Teach robust action contract design with input schemas, defaults, and safe validation failures",
  related: ["docs/concepts/actions", "docs/learn/signals-routing",
   "docs/learn/first-agent", "docs/learn/first-workflow"],
  source_files: ["lib/jido/action.ex"],
  source_modules: ["Jido.Action"],
  prompt_overrides: %{
    document_intent: "Write the training module on designing robust action contracts with clear input schemas, defaults, and validation.",
    required_sections: ["Action Contract Design", "Validation Flow", "Return Shape", "Domain Errors vs Validation Errors", "Testing Strategy", "Hands-on Exercise"],
    must_include: ["Validation at action boundaries — reject before touching state",
     "Defaults and required fields to reduce caller ambiguity",
     "Standardized return tuples: `{:ok, state_delta}` and `{:error, reason}`",
     "Separation of validation errors from business rule conflicts",
     "SetPriceAction exercise with boundary value testing"],
    must_avoid: ["Signal routing — that's the next module", "Complex multi-action composition"],
    required_links: ["/docs/concepts/actions", "/docs/learn/signals-routing",
     "/docs/learn/agent-fundamentals"],
    min_words: 800,
    max_words: 1_500,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Training module on designing robust action contracts with clear input schemas, defaults, and validation failures safe for upstream callers.

Cover:
- Validation at action boundaries — fail before state mutation
- Defaults, required fields, and return tuple standardization
- Domain errors vs validation errors
- SetPriceAction exercise with boundary value tests

### Validation Criteria

- Action contract patterns align with `Jido.Action` source API
- Error payloads include field-level detail in examples
- Tests cover happy path, boundary values, and failure payloads
- Links forward to signals-routing as the next training module
