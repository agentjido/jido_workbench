%{
  priority: :high,
  status: :outline,
  title: "Cookbook",
  repos: ["jido", "jido_ai", "jido_browser", "agent_jido"],
  tags: [:docs, :guides, :cookbook, :recipes, :hub_guides, :format_markdown, :wave_2],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/cookbook",
  ecosystem_packages: ["jido", "jido_ai", "jido_browser", "agent_jido"],
  learning_outcomes: ["Pick a practical recipe based on use case", "Run and adapt a minimal cookbook workflow"],
  order: 180,
  prerequisites: ["docs/getting-started", "docs/key-concepts"],
  purpose: "Provide runnable recipe-style workflows that can be copied into real projects",
  related: ["build/quickstarts-by-persona", "training/agent-fundamentals", "docs/guides"]
}
---
## Content Brief

Cookbook is the recipe index for runnable examples. It should group short workflows by problem type and link each recipe to deeper concept, reference, and operations docs.

### Validation Criteria

- Contains at least one recipe per core use case cluster.
- Every recipe links to one concept page and one operations page.
- Includes legacy route mapping notes for prior cookbook paths.
