%{
  priority: :critical,
  status: :outline,
  title: "Directives",
  repos: ["jido"],
  tags: [:docs, :concepts, :core, :directives],
  audience: :intermediate,
  content_type: :explanation,
  destination_collection: :pages,
  destination_route: "/docs/concepts/directives",
  ecosystem_packages: ["jido"],
  learning_outcomes: ["Explain how directives separate state transitions from side effects",
   "List directive types: emit, schedule, and their composition",
   "Understand how the runtime interprets and executes directives"],
  order: 50,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Document the directive primitive — declarative side-effect instructions returned by actions and interpreted by the runtime",
  related: ["docs/concepts/actions", "docs/concepts/agent-runtime",
   "docs/learn/directives-scheduling", "docs/learn/demand-tracker-agent"],
  source_files: ["lib/jido/agent/directive.ex"],
  source_modules: ["Jido.Agent.Directive"],
  prompt_overrides: %{
    document_intent: "Write the authoritative concept page for Jido Directives — declarative side-effect instructions.",
    required_sections: ["What Is a Directive?", "Directive Types", "Composition", "Runtime Interpretation", "Why Declarative Side Effects?"],
    must_include: ["Directives as data returned by actions, not executed inline",
     "Emit directives for signal publication",
     "Schedule directives for delayed or recurring work",
     "How the runtime (AgentServer) interprets directive lists",
     "Testability benefit: assert directive content without side effects"],
    must_avoid: ["Tutorial-style walkthroughs — link to Learn section",
     "Deep AgentServer implementation details"],
    required_links: ["/docs/concepts/actions", "/docs/concepts/agent-runtime",
     "/docs/learn/directives-scheduling"],
    min_words: 500,
    max_words: 1_000,
    minimum_code_blocks: 2,
    diagram_policy: "optional",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Authoritative concept page for Jido Directives — declarative side-effect instructions returned by actions and interpreted by the runtime.

Cover:
- Directives as data, not inline execution
- Emit and schedule directive types
- Directive composition from multi-action commands
- Runtime interpretation by AgentServer

### Validation Criteria

- Directive types align with `Jido.Agent.Directive` source module
- Runtime interpretation explanation matches AgentServer behavior
- Testability benefit is clearly articulated
- Links to directives-scheduling tutorial for hands-on practice
