%{
  name: "jido_claude",
  title: "Jido Claude",
  version: "0.1.0",
  tagline: "Claude Code adapter for Jido Harness with migration support for legacy session surfaces",
  license: "Apache-2.0",
  visibility: :private,
  category: :integrations,
  tier: 2,
  tags: [:claude, :anthropic, :cli, :harness, :coding],
  hex_url: "https://hex.pm/packages/jido_claude",
  hexdocs_url: "https://hexdocs.pm/jido_claude",
  github_url: "https://github.com/agentjido/jido_claude",
  github_org: "agentjido",
  github_repo: "jido_claude",
  elixir: "~> 1.18",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable — expect breaking changes",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex — available only via GitHub dependency",
    "Requires Claude Code CLI installed and authenticated",
    "Legacy Jido session/agent architecture still ships alongside the Harness adapter path"
  ],
  ecosystem_deps: ["jido_harness"],
  key_features: [
    "Implements `Jido.Harness.Adapter` for Claude Code execution",
    "Runtime contract support and normalized event mapping",
    "Compatibility bridge for legacy multi-session orchestration surfaces",
    "Typed lifecycle/event handling for session progress and outcomes",
    "Operational tasks for install, compatibility, and smoke verification"
  ]
}
---
## Overview

Jido Claude integrates Anthropic Claude Code into the Harness-based provider stack so Claude can run as a first-class coding adapter.

## Purpose

Jido Claude is the Claude-specific provider adapter with a transitional bridge between legacy session surfaces and the Harness contract path.

## Boundary Lines

- Owns Claude-specific adapter mapping, runtime contract wiring, and event normalization.
- Maintains compatibility surfaces while legacy session architecture is retired.
- Does not own provider-neutral contract governance or shared runtime policy.

## Major Components

### Harness Adapter

Implements provider callbacks and maps Harness requests into Claude Code CLI execution.

### Event Mapping

Normalizes provider lifecycle output into shared Harness event envelopes.

### Legacy Compatibility

Preserves migration paths from earlier session-agent patterns while adapter-centric flow matures.
