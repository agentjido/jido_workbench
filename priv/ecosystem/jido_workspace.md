%{
  name: "jido_workspace",
  title: "Jido Workspace",
  version: "0.1.0",
  tagline: "Unified artifact workspace for agent sessions on top of jido_shell and jido_vfs",
  license: "Apache-2.0",
  visibility: :private,
  category: :tools,
  tier: 2,
  tags: [:workspace, :artifacts, :shell, :vfs, :agents],
  github_url: "https://github.com/agentjido/jido_workspace",
  github_org: "agentjido",
  github_repo: "jido_workspace",
  elixir: "~> 1.18",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable - package and persistence interfaces may change",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Relies on jido_shell and jido_vfs integration maturity",
    "Current snapshot and execution semantics are still evolving"
  ],
  ecosystem_deps: ["jido_shell", "jido_vfs"],
  key_features: [
    "Unified workspace abstraction for file artifacts and command execution",
    "In-memory VFS-backed workspace creation and lifecycle operations",
    "Snapshot and restore support for speculative agent workflows",
    "Convenience API for read/write/list/delete artifact operations",
    "Shell execution integration for workspace-local command runs"
  ]
}
---
## Overview

Jido Workspace provides a unified artifact workspace abstraction for agent sessions, combining virtual filesystem and shell primitives.

## Purpose

Jido Workspace gives higher-level agent systems a consistent place to stage files, run commands, and checkpoint state.

## Major Components

### Workspace Core

Creates and manages workspace instances backed by VFS semantics.

### Artifact API

Supports common file operations and artifact inspection helpers.

### Snapshot Lifecycle

Allows checkpoint/restore workflows for reversible autonomous operations.

### Shell Integration

Runs commands against workspace state through jido_shell adapters.
