%{
  name: "jido_shell",
  title: "Jido Shell",
  version: "3.0.0",
  tagline: "Agent-friendly shell and session runtime built on top of jido_vfs",
  graph_label: "shell runtime",
  license: "Apache-2.0",
  visibility: :private,
  category: :tools,
  tier: 2,
  tags: [:shell, :cli, :sessions, :runtime, :tools],
  github_url: "https://github.com/agentjido/jido_shell",
  github_org: "agentjido",
  github_repo: "jido_shell",
  elixir: "~> 1.18",
  maturity: :stable,
  hex_status: "unreleased",
  api_stability: "stable core runtime with evolving integration policy around sprites/session controls",
  stub: false,
  support: :maintained,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Still carries a branch dependency on jido_vfs in some repo configurations",
    "Sprite coupling is intentional but introduces policy-heavy runtime concerns"
  ],
  ecosystem_deps: ["jido_vfs"],
  key_features: [
    "Mature shell/session lifecycle runtime on top of jido_vfs",
    "Consistent command execution primitives for autonomous agent workflows",
    "Session lifecycle helpers for start, stream, and teardown flows",
    "Foundation package used by harness runtime execution paths",
    "Provider-agnostic shell semantics with explicit policy boundaries"
  ]
}
---
## Overview

Jido Shell is the shell/session runtime layer in the CLI-agent stack. It provides predictable command execution and lifecycle semantics on top of jido_vfs so higher layers can operate across environments with consistent behavior.

## Purpose

Jido Shell provides the agent-friendly shell and session runtime used by harness and workspace-level orchestration.

## Boundary Lines

- Owns shell command execution and session lifecycle primitives.
- Builds directly on jido_vfs and provides runtime-safe interfaces upward.
- Does not own provider-specific adapter contracts or domain workflow orchestration.

## Major Components

### Command Runtime

Runs commands with predictable execution semantics and explicit lifecycle controls.

### Session Lifecycle

Tracks shell session startup, interaction, and teardown for long-lived agent tasks.

### Runtime Integration Surface

Supplies the shell primitives consumed by harness/provider execution layers.
