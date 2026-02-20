%{
  name: "jido_lib",
  title: "Jido Lib",
  version: "0.1.0",
  tagline: "Reusable standard-library style modules for common Jido automation workflows",
  license: "Apache-2.0",
  visibility: :private,
  category: :tools,
  tier: 2,
  tags: [:library, :workflows, :github, :automation],
  github_url: "https://github.com/agentjido/jido_lib",
  github_org: "agentjido",
  github_repo: "jido_lib",
  elixir: "~> 1.18",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable - module set and APIs are evolving",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Depends on adjacent workspace packages in active development",
    "Focuses on pragmatic workflow helpers more than long-term API stability"
  ],
  ecosystem_deps: ["jido", "jido_runic", "jido_action", "jido_shell", "jido_claude", "jido_vfs"],
  key_features: [
    "Canonical GitHub PR bot workflow API",
    "Canonical GitHub issue triage workflow API",
    "Signal-first agent orchestration helpers",
    "Composed integrations with shell, VFS, and Claude-based tooling",
    "Reusable implementation patterns for production automation agents"
  ]
}
---
## Overview

Jido Lib collects reusable higher-level modules for common agentic automation patterns, especially GitHub-centered triage and PR workflows.

## Purpose

Jido Lib provides a shared implementation layer teams can reuse instead of rebuilding the same workflow plumbing per project.

## Major Components

### GitHub Agent APIs

Includes canonical entry points for issue triage and PR bot orchestration.

### Workflow Composition

Builds on Jido action and runic primitives to model multi-step automation pipelines.

### Utility Modules

Provides practical helpers for integrating shell, workspace, and CLI-based agent components.
