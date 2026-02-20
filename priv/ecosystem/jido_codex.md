%{
  name: "jido_codex",
  title: "Jido Codex",
  version: "0.1.0",
  tagline: "OpenAI Codex CLI adapter implementing the Jido Harness protocol",
  license: "Apache-2.0",
  visibility: :public,
  category: :integrations,
  tier: 2,
  tags: [:codex, :openai, :cli, :harness, :coding],
  github_url: "https://github.com/agentjido/jido_codex",
  github_org: "agentjido",
  github_repo: "jido_codex",
  elixir: "~> 1.18",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable - adapter protocol still evolving",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Requires Codex CLI installed and authenticated",
    "Behavior can vary with Codex CLI and codex_sdk version changes"
  ],
  ecosystem_deps: ["jido_harness"],
  key_features: [
    "Implements `Jido.Harness.Adapter` for Codex-backed execution",
    "Streaming event normalization into Harness-compatible envelopes",
    "Exec transport by default with optional app-server transport",
    "Session-aware cancellation support",
    "Validation and smoke-test mix tasks for local setup"
  ]
}
---
## Overview

Jido Codex adapts OpenAI Codex CLI into the Jido Harness protocol so coding-agent workflows can run through a unified interface.

## Purpose

Jido Codex provides the Codex-specific provider layer for Jido Harness.

## Major Components

### Adapter

Translates Harness run requests into Codex CLI sessions and maps responses back into normalized events.

### Mapper

Normalizes streaming and lifecycle events for downstream agent orchestration.

### Operational Tasks

Includes install and compatibility checks to catch local environment issues early.
