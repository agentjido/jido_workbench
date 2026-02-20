%{
  name: "jido_memory",
  title: "Jido Memory",
  version: "0.1.0",
  tagline: "ETS-backed memory system and plugin model for Jido agents",
  license: "Apache-2.0",
  visibility: :public,
  category: :ai,
  tier: 2,
  tags: [:memory, :state, :plugin, :agents],
  github_url: "https://github.com/agentjido/jido_memory",
  github_org: "agentjido",
  github_repo: "jido_memory",
  elixir: "~> 1.18",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable - still shaping record/query model",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex - available via GitHub dependency",
    "Current implementation uses ETS as the authoritative store",
    "Long-term persistence backends and retention policies are still evolving"
  ],
  ecosystem_deps: ["jido", "jido_action", "jido_ai"],
  key_features: [
    "Structured memory records and query filters",
    "Jido plugin for memory integration into agent lifecycles",
    "Explicit actions for remember, recall, and forget workflows",
    "Auto-capture hooks for LLM and non-LLM signal flows",
    "Namespace-aware storage patterns for multi-agent systems"
  ]
}
---
## Overview

Jido Memory provides a data-driven memory layer for Jido agents with a practical ETS-backed implementation and action-based APIs.

## Purpose

Jido Memory gives agents explicit, inspectable memory operations instead of ad-hoc context mutation.

## Major Components

### Memory Models

Defines structured record and query representations for memory operations.

### Plugin

Ships an ETS plugin that can be mounted into agents for runtime memory behavior.

### Memory Actions

Exposes remember/recall/forget actions to compose memory workflows with the broader Jido action system.
