%{
  name: "jido_character",
  title: "Jido Character",
  version: "1.0.0",
  tagline: "Composable character definitions and context rendering for AI agents",
  license: "Apache-2.0",
  visibility: :public,
  category: :ai,
  tier: 2,
  tags: [:character, :persona, :prompting, :ai],
  github_url: "https://github.com/agentjido/jido_character",
  github_org: "agentjido",
  github_repo: "jido_character",
  elixir: "~> 1.17",
  maturity: :beta,
  hex_status: "unreleased",
  api_stability: "pre-1.0 style iteration under active development",
  stub: false,
  support: :best_effort,
  limitations: [
    "Hex package not currently published",
    "Prompt rendering conventions may evolve as req_llm integrations expand",
    "Persistence adapters are intentionally minimal by default"
  ],
  ecosystem_deps: ["req_llm"],
  key_features: [
    "Zoi-validated schemas for identity, voice, memory, and knowledge",
    "Immutable updates with version tracking",
    "`use Jido.Character` macro for reusable templates",
    "Direct rendering to req_llm context payloads",
    "Pluggable persistence adapter pattern with in-memory defaults"
  ]
}
---
## Overview

Jido Character defines a structured way to model agent personas and render them into LLM-ready context. It helps teams keep identity, style, and memory constraints explicit instead of scattering prompt fragments across the codebase.

## Purpose

Jido Character is the persona and context layer for agent workflows built with Jido and ReqLLM.

## Major Components

### Core Character API

Create, update, and validate character definitions as immutable data.

### Rendering

Convert character data into deterministic prompt/context blocks for model requests.

### Persistence

Adapter-based persistence lets applications choose memory-only or custom storage backends.
