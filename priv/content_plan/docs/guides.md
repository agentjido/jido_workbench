%{
  priority: :medium,
  status: :outline,
  title: "Guides Docs Hub",
  repos: ["agent_jido"],
  tags: [:docs, :guides, :navigation, :hub_guides, :format_markdown, :wave_1],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: ["Find guides by implementation or operations intent",
   "Progress from concept understanding to execution", "Identify when to switch from Build to Operate guidance"],
  order: 30,
  prerequisites: ["docs/overview"],
  purpose: "Aggregate implementation and operations guides in one routeable hub",
  related: ["build/ai-chat-agent", "build/multi-agent-workflows", "docs/agent-server",
   "docs/troubleshooting-and-debugging-playbook"],
  source_files: ["marketing/content-outline.md", "priv/content_plan/build/**/*.md", "priv/content_plan/docs/**/*.md"],
  source_modules: ["AgentJido.ContentPlan"]
}
---
## Content Brief

Guide index that separates build-time how-tos from post-launch operations guidance.

### Validation Criteria

- Includes category segmentation by lifecycle phase
- Includes direct links to troubleshooting and runbook content
- Keeps guide summaries concise and outcome-oriented
