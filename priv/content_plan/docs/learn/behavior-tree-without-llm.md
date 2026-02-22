%{
  priority: :high,
  status: :planned,
  title: "Behavior Tree Workflows Without LLM",
  repos: ["jido", "jido_behaviortree"],
  tags: [:docs, :learn, :build, :behavior_tree, :workflows],
  audience: :intermediate,
  content_type: :tutorial,
  destination_collection: :pages,
  destination_route: "/docs/learn/behavior-tree-without-llm",
  ecosystem_packages: ["jido", "jido_behaviortree"],
  learning_outcomes: ["Model agent decision logic as a behavior tree",
   "Compose selector, sequence, and condition nodes for branching workflows",
   "Execute behavior trees deterministically without LLM dependencies"],
  order: 42,
  prerequisites: ["docs/learn/first-workflow"],
  purpose: "Show how to use jido_behaviortree for structured decision workflows without requiring an LLM",
  related: ["docs/learn/first-workflow", "docs/learn/multi-agent-workflows",
   "docs/reference/packages/jido-behaviortree", "docs/concepts/actions"],
  source_modules: ["Jido.BehaviorTree"],
  prompt_overrides: %{
    document_intent: "Write a tutorial showing behavior tree workflows as a deterministic alternative to LLM-driven decision making.",
    required_sections: ["What Is a Behavior Tree?", "Define Nodes", "Build a Tree", "Execute and Inspect", "When to Use BTs vs LLMs"],
    must_include: ["Selector and sequence node composition",
     "Condition nodes for branching logic",
     "Full tree execution with deterministic output",
     "Comparison: when behavior trees are better than LLM-based decisions"],
    must_avoid: ["LLM integration — this is explicitly the non-LLM path",
     "Production deployment patterns"],
    required_links: ["/docs/learn/first-workflow", "/docs/reference/packages/jido-behaviortree",
     "/docs/learn/multi-agent-workflows"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 4,
    diagram_policy: "recommended",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Tutorial showing behavior tree workflows as a deterministic, LLM-free approach to structured agent decision logic.

Cover:
- Behavior tree concepts: selectors, sequences, conditions
- Composing a decision tree from node primitives
- Executing a tree and inspecting deterministic output
- When to choose behavior trees over LLM-based reasoning

### Validation Criteria

- Code uses current jido_behaviortree API
- Tree execution produces deterministic, testable output
- Includes honest comparison of BT vs LLM trade-offs
- Diagram shows tree structure visually
