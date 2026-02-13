%{
  title: "Guides Docs Hub",
  order: 30,
  purpose: "Aggregate implementation and operations guides in one routeable hub",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Find guides by implementation or operations intent",
    "Progress from concept understanding to execution",
    "Identify when to switch from Build to Operate guidance"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.ContentPlan"],
  source_files: ["marketing/content-outline.md", "priv/content_plan/build/**/*.md", "priv/content_plan/operate/**/*.md"],
  status: :outline,
  priority: :medium,
  prerequisites: ["docs/overview"],
  related: ["build/ai-chat-agent", "build/multi-agent-workflows", "operate/agent-server", "operate/troubleshooting-and-debugging-playbook"],
  ecosystem_packages: ["agent_jido"],
  tags: [:docs, :guides, :navigation]
}
---
## Content Brief

Guide index that separates build-time how-tos from post-launch operations guidance.

### Validation Criteria

- Includes category segmentation by lifecycle phase
- Includes direct links to troubleshooting and runbook content
- Keeps guide summaries concise and outcome-oriented
