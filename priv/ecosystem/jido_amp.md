%{
  name: "jido_amp",
  title: "Jido Amp",
  version: "0.1.0",
  tagline: "Amp CLI adapter for Jido agents with streaming session lifecycle management",
  license: "Apache-2.0",
  visibility: :private,
  category: :integrations,
  tier: 2,
  tags: [:amp, :cli, :agents, :coding, :integration],
  github_url: "https://github.com/agentjido/jido_amp",
  github_org: "agentjido",
  github_repo: "jido_amp",
  elixir: "~> 1.18",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable - expect breaking changes",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Requires Amp CLI installed and authenticated",
    "Streaming compatibility depends on amp_sdk and CLI flag support"
  ],
  ecosystem_deps: ["jido"],
  key_features: [
    "Jido agent wrapper for Amp session lifecycle and streaming event routing",
    "Fail-fast compatibility checks for CLI streaming mode",
    "Top-level API plus namespaced modules for threads and tools",
    "Session cancellation and structured signal mapping",
    "Operational mix tasks for install, compatibility, and smoke testing"
  ]
}
---
## Overview

Jido Amp integrates the Amp CLI SDK with the Jido ecosystem so agents can run Amp-powered coding workflows through a structured Elixir API. It focuses on reliable session lifecycle control and streaming event normalization.

## Purpose

Jido Amp provides a bridge between Amp CLI workflows and Jido agent orchestration patterns.

## Major Components

### `Jido.Amp.Agent`

Manages Amp session lifecycle and routes stream events into agent-friendly state transitions.

### API Modules

Provides top-level orchestration helpers and namespaced modules for threads and tool operations.

### Operational Tasks

Includes mix tasks to validate local Amp setup and runtime compatibility before executing workflows.
