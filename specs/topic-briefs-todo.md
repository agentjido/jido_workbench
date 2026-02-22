# Content Brief Creation — Todo List

Source: specs/brainstorms/route-topic-breakdown.md
Template: priv/content_plan/docs/concepts/agents.md (frontmatter + prompt_overrides + content brief)

---

## How to Write a Brief

Each brief is a `.md` file with two parts: **Elixir map frontmatter** and a **Content Brief** section.

### Frontmatter

The file starts with an Elixir map (`%{ ... }`) terminated by `---`. Required fields:

| Field                    | Purpose                                                            |
| ------------------------ | ------------------------------------------------------------------ |
| `priority`               | `:critical`, `:high`, or `:medium`                                 |
| `status`                 | `:planned` (new), `:outline`, `:draft`, `:review`, or `:published` |
| `title`                  | Page title as shown in nav                                         |
| `destination_route`      | Canonical URL path (e.g., `/docs/learn/first-agent`)               |
| `destination_collection` | Always `:pages`                                                    |
| `order`                  | Sort position within section (10, 20, 30…)                         |
| `purpose`                | One sentence — why this page exists                                |
| `audience`               | `:beginner`, `:intermediate`, or `:advanced`                       |
| `content_type`           | `:tutorial`, `:guide`, `:explanation`, or `:reference`             |
| `learning_outcomes`      | List of 2–4 concrete outcomes                                      |
| `prerequisites`          | List of brief IDs the reader should have completed                 |
| `related`                | List of brief IDs for cross-linking                                |
| `repos`                  | Which source repos are relevant                                    |
| `ecosystem_packages`     | Hex packages covered                                               |
| `tags`                   | Categorization tags                                                |

Optional but encouraged:

| Field              | Purpose                                                       |
| ------------------ | ------------------------------------------------------------- |
| `legacy_paths`     | Old URLs that need redirects (e.g., `["/build/first-agent"]`) |
| `source_files`     | Source code files to reference when writing                   |
| `source_modules`   | Elixir modules to reference when writing                      |
| `prompt_overrides` | Map of generation constraints (see below)                     |

### `prompt_overrides` (the good stuff)

This map tells the content generator exactly what to produce. Include as many as apply:

```elixir
prompt_overrides: %{
  document_intent: "One sentence describing what this page should accomplish.",
  required_sections: ["Section 1", "Section 2"],
  must_include: ["Specific thing the page must cover", "Another requirement"],
  must_avoid: ["What to stay away from"],
  required_links: ["/docs/concepts/agents", "/docs/learn/first-agent"],
  min_words: 500,
  max_words: 1_200,
  minimum_code_blocks: 2,
  diagram_policy: "none" | "optional" | "recommended",
  section_density: "minimal" | "light_technical",
  max_paragraph_sentences: 3
}
```

### Content Brief section

Below the `---`, write a short brief (2–6 lines) summarizing the page's purpose, followed by `### Validation Criteria` with 3–4 bullet points that a reviewer can check against the finished page.

### Example (minimal)

```markdown
%{
priority: :high,
status: :draft,
title: "Signals",
destination_route: "/docs/concepts/signals",
destination_collection: :pages,
order: 40,
purpose: "Document typed message envelopes and routing patterns",
audience: :intermediate,
content_type: :guide,
learning_outcomes: ["Create stable signal contracts", "Route signals safely"],
prerequisites: ["docs/concepts/key-concepts"],
related: ["docs/concepts/actions", "docs/concepts/agent-runtime"],
repos: ["jido_signal", "jido"],
ecosystem_packages: ["jido_signal", "jido"],
tags: [:docs, :core, :signals],
source_modules: ["Jido.Signal"],
prompt_overrides: %{
document_intent: "Write the authoritative guide to Jido Signals.",
required_sections: ["Signal Structure", "Routing Patterns"],
must_include: ["Signal fields aligned with source", "Idempotency considerations"],
must_avoid: ["Duplicating tutorial content from Learn section"],
required_links: ["/docs/concepts/agents", "/docs/learn/signals-routing"],
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

Signal structure, metadata, routing, and practical coordination guidance.

### Validation Criteria

- Signal fields and helpers align with source definitions
- Routing guidance reflects runtime behavior in AgentServer
- Includes idempotency and duplicate-delivery considerations
```

---

## `/docs` — Top-level (3 files)

- [x] `docs/_section.md`
- [x] `docs/_hub.md` — Docs Overview
- [x] `docs/getting-started.md` — Getting Started

## `/docs/learn` — Tutorials and progressive build guides (22 files)

### Hub

- [x] `docs/learn/_hub.md` — Learn Hub

### Onboarding ladder (Theme 1)

- [x] `docs/learn/installation.md` — Installation and Setup _(moved from /build/installation)_
- [x] `docs/learn/first-agent.md` — Build Your First Agent (no LLM) _(moved from /build/first-agent)_
- [x] `docs/learn/first-llm-agent.md` — Build Your First LLM Agent `[NEW]`
- [x] `docs/learn/first-workflow.md` — Build Your First Workflow `[NEW]`
- [x] `docs/learn/why-not-just-a-genserver.md` — Why Not Just a GenServer? `[NEW]`
- [x] `docs/learn/quickstarts-by-persona.md` — Quickstarts by Persona _(moved from /build/quickstarts-by-persona)_

### Training modules (Theme 14)

- [x] `docs/learn/agent-fundamentals.md` — Agent Fundamentals on the BEAM _(moved from /training/agent-fundamentals, published)_
- [x] `docs/learn/actions-validation.md` — Actions and Schema Validation _(moved from /training/actions-validation, published)_
- [x] `docs/learn/signals-routing.md` — Signals, Routing, and Agent Communication _(moved from /training/signals-routing, published)_
- [x] `docs/learn/directives-scheduling.md` — Directives, Scheduling, and Time-Based Behavior _(moved from /training/directives-scheduling, published)_
- [x] `docs/learn/liveview-integration.md` — LiveView and Jido Integration Patterns _(moved from /training/liveview-integration, published)_
- [x] `docs/learn/production-readiness.md` — Production Readiness _(moved from /training/production-readiness, published)_

### Build guides (Theme 4)

- [x] `docs/learn/counter-agent.md` — Counter Agent Example _(moved from /build/counter-agent, published)_
- [x] `docs/learn/demand-tracker-agent.md` — Demand Tracker Agent Example _(moved from /build/demand-tracker-agent, published)_
- [x] `docs/learn/behavior-tree-without-llm.md` — Behavior Tree Workflows Without LLM `[NEW]`
- [x] `docs/learn/ai-chat-agent.md` — Build an AI Chat Agent _(moved from /build/ai-chat-agent)_
- [x] `docs/learn/tool-use.md` — Tool Use and Function Calling _(moved from /build/tool-use)_
- [x] `docs/learn/multi-agent-workflows.md` — Multi-Agent Workflows _(moved from /build/multi-agent-workflows)_
- [x] `docs/learn/mixed-stack-integration.md` — Mixed-Stack Integration _(moved from /build/mixed-stack-integration)_
- [x] `docs/learn/reference-architectures.md` — Reference Architectures _(moved from /build/reference-architectures)_
- [x] `docs/learn/product-feature-blueprints.md` — Product Feature Blueprints _(moved from /build/product-feature-blueprints)_

## `/docs/concepts` — Core primitives (8 files)

- [x] `docs/concepts/_hub.md` — Core Concepts Hub
- [x] `docs/concepts/key-concepts.md` — Key Concepts
- [x] `docs/concepts/agents.md` — Agents
- [x] `docs/concepts/actions.md` — Actions
- [x] `docs/concepts/signals.md` — Signals
- [x] `docs/concepts/directives.md` — Directives
- [x] `docs/concepts/agent-runtime.md` — Agent Runtime (AgentServer)
- [x] `docs/concepts/plugins.md` — Plugins

## `/docs/guides` — How-to guides and patterns (12 files)

- [x] `docs/guides/_hub.md` — Guides Hub
- [x] `docs/guides/retries-backpressure-and-failure-recovery.md` — Retries, Backpressure, and Failure Recovery
- [x] `docs/guides/long-running-agent-workflows.md` — Long-Running Agent Workflows
- [x] `docs/guides/persistence-memory-and-vector-search.md` — Persistence, Memory, and Vector Search
- [x] `docs/guides/testing-agents-and-actions.md` — Testing Agents and Actions
- [x] `docs/guides/troubleshooting-and-debugging-playbook.md` — Troubleshooting and Debugging Playbook
- [x] `docs/guides/mcp-integration.md` — MCP Integration Guide `[NEW]`
- [x] `docs/guides/mixed-stack-runbooks.md` — Mixed-Stack Runbooks
- [x] `docs/guides/cookbook/_hub.md` — Cookbook
- [x] `docs/guides/cookbook/chat-response.md` — Cookbook: Chat Response _(published)_
- [x] `docs/guides/cookbook/tool-response.md` — Cookbook: Tool Response _(published)_
- [x] `docs/guides/cookbook/weather-tool-response.md` — Cookbook: Weather Tool Response _(published)_

## `/docs/operations` — Production ops and reliability (5 files)

- [x] `docs/operations/_hub.md` — Operations Hub
- [x] `docs/operations/production-readiness-checklist.md` — Production Readiness Checklist
- [x] `docs/operations/security-and-governance.md` — Security and Governance
- [x] `docs/operations/incident-playbooks.md` — Incident Playbooks
- [x] `docs/operations/backup-and-disaster-recovery.md` — Backup and Disaster Recovery `[NEW]`

## `/docs/reference` — API contracts, config, architecture (11 files)

- [x] `docs/reference/_hub.md` — Reference Hub
- [x] `docs/reference/architecture.md` — Architecture Overview
- [x] `docs/reference/ai-integration-decision-guide.md` — AI Integration Decision Guide `[NEW]`
- [x] `docs/reference/provider-capability-and-fallback-matrix.md` — Provider Capability and Fallback Matrix `[NEW]`
- [x] `docs/reference/configuration.md` — Configuration Reference
- [x] `docs/reference/architecture-decision-guides.md` — Architecture Decision Guides
- [x] `docs/reference/telemetry-and-observability.md` — Telemetry and Observability Reference
- [x] `docs/reference/data-storage-and-pgvector.md` — Data Storage and pgvector Reference
- [x] `docs/reference/glossary.md` — Glossary
- [x] `docs/reference/migrations-and-upgrade-paths.md` — Migrations and Upgrade Paths
- [x] `docs/reference/content-governance-and-drift-detection.md` — Content Governance and Drift Detection

## `/docs/reference/packages` — Package API references (11 files)

- [x] `docs/reference/packages/jido.md` — Package Reference: jido
- [x] `docs/reference/packages/jido-action.md` — Package Reference: jido_action
- [x] `docs/reference/packages/jido-signal.md` — Package Reference: jido_signal
- [x] `docs/reference/packages/jido-ai.md` — Package Reference: jido_ai
- [x] `docs/reference/packages/req-llm.md` — Package Reference: req_llm
- [x] `docs/reference/packages/jido-runic.md` — Package Reference: jido_runic `[NEW]`
- [x] `docs/reference/packages/jido-browser.md` — Package Reference: jido_browser
- [x] `docs/reference/packages/agent-jido.md` — Package Reference: agent_jido
- [x] `docs/reference/packages/jido-memory.md` — Package Reference: jido_memory `[NEW]`
- [x] `docs/reference/packages/jido-otel.md` — Package Reference: jido_otel `[NEW]`
- [x] `docs/reference/packages/jido-behaviortree.md` — Package Reference: jido_behaviortree `[NEW]`

## `/docs/community` — Adoption enablement (5 files)

- [x] `docs/community/_hub.md` — Community Hub
- [x] `docs/community/adoption-playbooks.md` — Adoption Playbooks _(moved from /community/adoption-playbooks)_
- [x] `docs/community/case-studies.md` — Case Studies _(moved from /community/case-studies)_
- [x] `docs/community/learning-paths.md` — Learning Paths _(moved from /community/learning-paths)_
- [x] `docs/community/manager-roadmap.md` — Manager Adoption Roadmap _(moved from /training/manager-roadmap)_

---

## Summary

| Section                    | Total  | Done   | Remaining |
| -------------------------- | ------ | ------ | --------- |
| `/docs` (top-level)        | 3      | 3      | 0         |
| `/docs/learn`              | 22     | 22     | 0         |
| `/docs/concepts`           | 8      | 8      | 0         |
| `/docs/guides`             | 12     | 12     | 0         |
| `/docs/operations`         | 5      | 5      | 0         |
| `/docs/reference`          | 11     | 11     | 0         |
| `/docs/reference/packages` | 11     | 11     | 0         |
| `/docs/community`          | 5      | 5      | 0         |
| **Total**                  | **77** | **77** | **0**     |

`[NEW]` = 12 pages with no prior content brief (need full creation from scratch)
All others have prior briefs in `build/`, `training/`, `community/`, or flat `docs/` that were read before deletion — use those as source material for the new briefs.
