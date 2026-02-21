%{
  name: "jido_amp",
  title: "Jido Amp",
  version: "0.1.0",
  tagline: "Amp CLI adapter for Jido Harness with runtime compatibility checks",
  license: "Apache-2.0",
  visibility: :private,
  category: :integrations,
  tier: 2,
  tags: [:amp, :cli, :agents, :coding, :integration],
  github_url: "https://github.com/agentjido/jido_amp",
  github_org: "agentjido",
  github_repo: "jido_amp",
  elixir: "~> 1.18",
  maturity: :beta,
  hex_status: "unreleased",
  api_stability: "unstable - expect breaking changes",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Requires Amp CLI installed and authenticated",
    "Upstream amp_sdk dependency is currently branch-pinned"
  ],
  ecosystem_deps: ["jido_harness"],
  key_features: [
    "Implements `Jido.Harness.Adapter` for Amp-backed execution",
    "Runtime contract and compatibility checks for local CLI readiness",
    "Streaming event routing into Harness-compatible envelopes",
    "Session cancellation and structured signal mapping",
    "Operational mix tasks for install, compatibility, and smoke testing"
  ]
}
---
## Overview

Jido Amp integrates Amp CLI workflows into the Harness-based provider stack so Amp can run as a first-class coding provider.

## Purpose

Jido Amp is the Amp-specific provider adapter for Harness-driven coding workflows.

## Boundary Lines

- Owns Amp-specific adapter mapping, compatibility checks, and stream normalization.
- Implements capabilities through the shared Harness contract model.
- Does not own provider-neutral runtime policy, contract governance, or domain orchestration.

## Major Components

### Adapter

Manages Amp execution lifecycle and maps run requests into provider-specific commands.

### Event Mapping

Routes streamed provider output into normalized Harness event envelopes.

### Operational Tasks

Includes mix tasks to validate local Amp setup and runtime compatibility before executing workflows.
