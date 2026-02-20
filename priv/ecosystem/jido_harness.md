%{
  name: "jido_harness",
  title: "Jido Harness",
  version: "0.1.0",
  tagline: "Unified Elixir protocol for CLI AI coding agent providers",
  license: "Apache-2.0",
  visibility: :public,
  category: :core,
  tier: 2,
  tags: [:harness, :protocol, :coding, :adapters],
  github_url: "https://github.com/agentjido/jido_harness",
  github_org: "agentjido",
  github_repo: "jido_harness",
  elixir: "~> 1.18",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable - protocol surface is still maturing",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Provider behavior depends on external CLIs and adapter maturity",
    "Streaming/event standards may evolve before a stable release"
  ],
  ecosystem_deps: [],
  key_features: [
    "Provider-agnostic behavior contract for CLI coding agents",
    "Normalized run/stream/cancel lifecycle abstractions",
    "Schema-validated request and event payload models",
    "Configurable provider registry and default-provider selection",
    "Foundation package for Codex, Gemini, and Amp adapter packages"
  ]
}
---
## Overview

Jido Harness standardizes how Elixir applications interact with CLI-based coding agents. It defines the core protocol, schemas, and error model that provider adapters implement.

## Purpose

Jido Harness is the common interoperability layer for multi-provider coding-agent workflows in the ecosystem.

## Major Components

### Adapter Behavior

Defines the required callbacks and contracts for provider implementations.

### Schemas and Errors

Provides consistent request/event structures and normalized error types.

### Provider Registry

Supports explicit and default provider resolution so applications can switch providers without changing call sites.
