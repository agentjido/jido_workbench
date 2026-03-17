%{
  title: "Ecosystem Atlas",
  description: "Public package roster for the Jido ecosystem with support levels, package owners, release status, and role in the stack.",
  category: :docs,
  legacy_paths: [],
  tags: [:docs, :contributors, :ecosystem, :ownership],
  order: 1,
  menu_label: "Ecosystem Atlas"
}
---

Package detail pages live under [/ecosystem](/ecosystem). Support definitions live in [Package Support Levels](/docs/contributors/package-support-levels). Roadmap sequencing lives in [Roadmap](/docs/contributors/roadmap). This page keeps the public-only slice of the current `jido_brainstorm` ecosystem groupings so contributors can map package ownership and status without pulling in private or external work.

## Integration / Framework

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Ash Jido](/ecosystem/ash_jido) | Stable | `@mikehostetler` | `unreleased` | Compile-time bridge from Ash resources to Jido Action modules. |

## Core / Runtime

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido](/ecosystem/jido) | Stable | `@mikehostetler` | `2.1.0` | Core agent framework for autonomous, multi-agent systems in Elixir. |
| [Jido Action](/ecosystem/jido_action) | Stable | `@mikehostetler` | `2.1.1` | Composable, validated command pattern with built-in AI tool integration. |
| [Jido Signal](/ecosystem/jido_signal) | Stable | `@mikehostetler` | `2.0.0` | CloudEvents-based event and communication toolkit for Elixir systems. |

## AI / LLM

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido AI](/ecosystem/jido_ai) | Stable | `@mikehostetler` | `2.0.0` | LLM orchestration, reasoning strategies, and accuracy controls for Jido agents. |
| [ReqLLM](/ecosystem/req_llm) | Stable | `@mikehostetler` | `1.7.1` | Req-based library for provider-neutral LLM interactions. |
| [Jido Character](/ecosystem/jido_character) | Stable | `@mikehostetler` | `unreleased` | Character definitions and context rendering for AI agents. |
| [LLMDB](/ecosystem/llm_db) | Stable | `@mikehostetler` | `2026.3.2` | Fast, zero-network LLM model metadata catalog for Elixir. |

## Messaging

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido Chat](/ecosystem/jido_chat) | Beta | `@mikehostetler` | `unreleased` | SDK-first chat core for typed message flows and adapter contracts. |
| [Jido Chat Discord](/ecosystem/jido_chat_discord) | Beta | `@mikehostetler` | `unreleased` | Discord adapter package implementing the Jido Chat contract. |
| [Jido Chat Telegram](/ecosystem/jido_chat_telegram) | Beta | `@mikehostetler` | `unreleased` | Telegram adapter package implementing the Jido Chat contract. |
| [Jido Messaging](/ecosystem/jido_messaging) | Beta | `@mikehostetler` | `unreleased` | Platform-agnostic messaging for AI agents across channel adapters. |

## Harness / CLI

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido Amp](/ecosystem/jido_amp) | Beta | `@mikehostetler` | `unreleased` | Amp CLI adapter for Jido Harness with runtime checks. |
| [Jido Claude](/ecosystem/jido_claude) | Beta | `@mikehostetler` | `unreleased` | Claude Code adapter for Jido Harness. |
| [Jido Codex](/ecosystem/jido_codex) | Beta | `@mikehostetler` | `unreleased` | OpenAI Codex adapter for Jido Harness. |
| [Jido Gemini](/ecosystem/jido_gemini) | Beta | `@mikehostetler` | `unreleased` | Google Gemini adapter for Jido Harness. |
| [Jido Harness](/ecosystem/jido_harness) | Beta | `@mikehostetler` | `unreleased` | Provider-neutral contract and runtime policy layer for CLI coding agents. |
| [Jido OpenCode](/ecosystem/jido_opencode) | Beta | `@mikehostetler` | `unreleased` | OpenCode CLI adapter for Jido Harness. |

## Planning / Control

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido BehaviorTree](/ecosystem/jido_behaviortree) | Stable | `@mikehostetler` | `unreleased` | Behavior tree engine for Jido agent decision-making. |
| [Jido Evolve](/ecosystem/jido_evolve) | Beta | `@mikehostetler` | `unreleased` | Evolutionary optimization toolkit with pluggable fitness pipelines. |

## Runtime / Interfaces

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido Browser](/ecosystem/jido_browser) | Stable | `@mikehostetler` | `2.0.0` | Browser automation for AI agents with composable actions. |
| [Jido MCP](/ecosystem/jido_mcp) | Beta | `@mikehostetler` | `unreleased` | MCP integration package with pooled clients and Jido action surfaces. |
| [Jido Runic](/ecosystem/jido_runic) | Stable | `@mikehostetler` | `unreleased` | Workflow composition and execution substrate for DAG-based orchestration. |
| [Jido Shell](/ecosystem/jido_shell) | Stable | `@mikehostetler` | `unreleased` | Agent-friendly shell and session runtime built on `jido_vfs`. |
| [Jido VFS](/ecosystem/jido_vfs) | Stable | `@mikehostetler` | `unreleased` | Backend-agnostic filesystem contract for agents and sandbox adapters. |
| [Jido Workspace](/ecosystem/jido_workspace) | Beta | `@mikehostetler` | `unreleased` | Workspace state and artifact lifecycle library for agent sessions. |

## Runtime / Distributed

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido Cluster](/ecosystem/jido_cluster) | Experimental | `@mikehostetler` | `unreleased` | Distributed keyed instance management and storage for multi-node runtimes. |

## Memory / Storage

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido Bedrock](/ecosystem/jido_bedrock) | Experimental | `@mikehostetler` | `unreleased` | Bedrock-backed persistence adapters for Jido runtimes. |
| [Jido Memory](/ecosystem/jido_memory) | Stable | `@mikehostetler` | `unreleased` | ETS-backed memory system and plugin model for Jido agents. |
| [Jido MemoryOS](/ecosystem/jido_memory_os) | Stable | `@pcharbon70` | `unreleased` | Tiered memory orchestration and governance layer for Jido agents. |

## Observability / Telemetry

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido OTEL](/ecosystem/jido_otel) | Beta | `@mikehostetler` | `unreleased` | OpenTelemetry tracer bridge for Jido instrumentation. |

## Developer Tools / UI

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido Live Dashboard](/ecosystem/jido_live_dashboard) | Beta | `@mikehostetler` | `unreleased` | Real-time observability and debugging in Phoenix LiveDashboard. |
| [Jido Studio](/ecosystem/jido_studio) | Beta | `@mikehostetler` | `unreleased` | LiveView dashboard for managing and debugging Jido agents. |

## Automation / Bots

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido Lib](/ecosystem/jido_lib) | Beta | `@mikehostetler` | `unreleased` | GitHub triage and PR orchestration workflows over the CLI-agent stack. |

## Evaluation / Testing

| Package | Support | Owner | Release | Purpose |
| --- | --- | --- | --- | --- |
| [Jido Eval](/ecosystem/jido_eval) | Experimental | `@mikehostetler` | `unreleased` | Evaluation framework for LLM and Jido agent quality measurement. |

## Next Steps

- [Package Support Levels](/docs/contributors/package-support-levels) - see what each support label commits the project to
- [Roadmap](/docs/contributors/roadmap) - understand which package groups are current focus areas
- [Ecosystem](/ecosystem) - open package detail pages for deeper docs and links
