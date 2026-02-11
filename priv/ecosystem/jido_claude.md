%{
  name: "jido_claude",
  title: "Jido Claude",
  version: "0.1.0",
  tagline: "Claude Code CLI integration for Jido agents with multi-session orchestration",
  license: "Apache-2.0",
  visibility: :public,
  category: :ai,
  tier: 2,
  tags: [:claude, :anthropic, :cli, :coding, :orchestration],
  hex_url: "https://hex.pm/packages/jido_claude",
  hexdocs_url: "https://hexdocs.pm/jido_claude",
  github_url: "https://github.com/agentjido/jido_claude",
  github_org: "agentjido",
  github_repo: "jido_claude",
  ecosystem_deps: ["jido"],
  key_features: [
    "Two-agent architecture — parent orchestrator with child session agents",
    "Multiple concurrent Claude Code sessions managed in parallel",
    "Full session lifecycle management — status, turns, transcripts, costs, errors",
    "Signal-based communication with typed Jido Signals for all session events",
    "Configurable Claude models — Haiku, Sonnet, and Opus per session",
    "Tool access control for each session",
    "Custom system prompts per session",
    "Automatic USD cost tracking per session and aggregated",
    "Session registry with querying, filtering, and statistics",
    "Graceful cancellation from session agent or parent orchestrator"
  ]
}
---
## Overview

Jido Claude integrates Anthropic's Claude Code CLI into the Jido Agent framework, enabling Elixir applications to programmatically run Claude Code sessions as first-class Jido agents. It provides a two-agent architecture where a parent orchestrator can spawn and manage multiple concurrent Claude Code sessions, each running independently and emitting structured signals for every turn, tool call, and result.

Rather than wrapping a simple API call, Jido Claude treats each Claude session as a full agent lifecycle — with state tracking, signal-based communication, session registries, and graceful cancellation.

## Purpose

Jido Claude serves as the bridge between the Jido agent ecosystem and Anthropic's Claude Code CLI. It wraps the `claude_agent_sdk` Elixir package with Jido's agent primitives — actions, signals, directives, and state management — so that Claude Code sessions can be orchestrated like any other Jido agent.

## Major Components

### Core
ClaudeSessionAgent managing a single session lifecycle with state tracking, StreamRunner for fire-and-forget query execution with streaming, and Signal builder for typed session events.

### Actions
StartSession (validate params, spawn runner, transition to running), HandleMessage (process stream events into state updates and signals), and CancelSession (cancel with signal emission).

### Parent Integration
SpawnSession action for orchestrators, HandleSessionEvent for processing child signals, CancelSession from parent, and SessionRegistry for managing multiple concurrent sessions with querying and cost aggregation.
