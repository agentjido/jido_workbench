%{
  name: "jido_skill",
  title: "Jido Skill",
  graph_label: "Jido Skill",
  version: "0.1.0",
  tagline: "Skill-only runtime for markdown-defined skills with signal-first dispatch",
  license: "Apache-2.0",
  visibility: :private,
  category: :tools,
  tier: 2,
  tags: [:skills, :markdown, :cli, :signals, :runtime],
  github_url: "https://github.com/agentjido/jido_skill",
  github_org: "agentjido",
  github_repo: "jido_skill",
  elixir: "~> 1.18",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable - pre-1.0 skill dispatch and registry behavior may change",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Skill conventions are markdown/file-structure driven and still evolving",
    "Registry and route dispatch APIs are pre-1.0 and subject to change"
  ],
  ecosystem_deps: ["jido"],
  key_features: [
    "Skill-only runtime centered on markdown-defined skill files",
    "Signal-first skill dispatch with route-level invocation support",
    "CLI and mix-task surfaces for run/list/reload/routes/watch flows",
    "Runtime route inspection and signal publication utilities",
    "Local executable workflow via escript build/install"
  ]
}
---
## Overview

Jido Skill is a markdown-centric runtime for defining and executing skills with signal-first dispatch. It focuses on discovery, routing, and operational control for skill catalogs.

## Purpose

Jido Skill is the dedicated skill runtime package for teams standardizing markdown-based skill workflows in Jido environments.

## Boundary Lines

- Owns skill discovery, routing, dispatch, and lifecycle observability for skill execution.
- Provides CLI and mix-task operational interfaces for skill runtime workflows.
- Does not own general command orchestration, chat transport integration, or provider-specific adapter behavior.

## Major Components

### Skill Registry

Discovers and indexes markdown-defined skills with reload support.

### Dispatch Surface

Supports route-driven skill invocation with signal-first runtime behavior.

### CLI and Mix Tasks

Provides commands for run/list/reload/routes/watch/signal operations in local environments.

### Runtime Observability

Exposes lifecycle signal streams for tracking skill execution and registry events.

