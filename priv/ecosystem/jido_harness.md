%{
  name: "jido_harness",
  title: "Jido Harness",
  version: "0.1.0",
  tagline: "Provider-neutral contract and runtime policy layer for CLI coding agents",
  license: "Apache-2.0",
  visibility: :private,
  category: :core,
  tier: 2,
  tags: [:harness, :protocol, :runtime, :cli, :adapters],
  github_url: "https://github.com/agentjido/jido_harness",
  github_org: "agentjido",
  github_repo: "jido_harness",
  elixir: "~> 1.18",
  maturity: :beta,
  hex_status: "unreleased",
  api_stability: "evolving - protocol and runtime surfaces are consolidating",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Owns both adapter protocol and runtime execution concerns, so boundaries are still being consolidated",
    "Current design is coupled to shell and sprites runtime policy concerns"
  ],
  ecosystem_deps: ["jido_shell", "jido_vfs"],
  key_features: [
    "Provider-agnostic `Jido.Harness.Adapter` contract for CLI coding agents",
    "Normalized run, stream, and cancel lifecycle abstractions",
    "Runtime execution modules under `Jido.Harness.Exec.*`",
    "Schema-validated request, event, and runtime contract models",
    "Architectural center for multi-provider adapter packages"
  ]
}
---
## Overview

Jido Harness standardizes how Elixir applications interact with CLI coding agents across providers. It defines the contract adapters implement and provides runtime execution modules for preflight, provider runtime, workspace, and streaming orchestration.

## Purpose

Jido Harness is the provider-neutral contract and runtime orchestration center for the CLI-agent ecosystem.

## Boundary Lines

- Owns the adapter behavior, request/event contracts, and runtime contract model.
- Provides shared runtime orchestration policy through `Jido.Harness.Exec.*`.
- Does not own provider-specific UX/session semantics or domain-specific workflow logic.

## Major Components

### Adapter Behavior

Defines required callbacks and interoperability contracts for provider implementations.

### Schemas and Errors

Provides consistent request/event structures and normalized error types.

### Runtime Execution

Implements shared preflight, provider runtime, workspace, and stream orchestration modules.

### Provider Registry

Supports explicit and default provider resolution so applications can switch providers without changing call sites.
