%{
  name: "req_llm",
  title: "ReqLLM",
  version: "1.5.1",
  tagline: "Composable Elixir library for LLM interactions built on Req",
  license: "Apache-2.0",
  visibility: :public,
  category: :ai,
  tier: 1,
  tags: [:llm, :ai, :http, :streaming],
  hex_url: "https://hex.pm/packages/req_llm",
  hexdocs_url: "https://hexdocs.pm/req_llm",
  github_url: "https://github.com/agentjido/req_llm",
  github_org: "agentjido",
  github_repo: "req_llm",
  elixir: "~> 1.17",
  ecosystem_deps: [],
  key_features: [
    "Unified multi-provider API across Anthropic, OpenAI, Google, Groq, xAI, and more",
    "Two-layer architecture — high-level Vercel AI SDK-style functions and low-level Req plugin API",
    "665+ model registry auto-synced from models.dev",
    "Production-grade streaming with HTTP/2 multiplexing and early cancellation",
    "Structured object generation with schema validation",
    "Tool/function calling with NimbleOptions schemas",
    "Per-request usage and cost tracking with telemetry",
    "Multi-modal content support (text, image, tool calls)",
    "Secure layered API key management"
  ]
}
---
## Overview

ReqLLM is a composable Elixir library for LLM interactions built on Req and Finch. It provides a unified, idiomatic Elixir interface that standardizes requests and responses across LLM providers — eliminating the need to learn and maintain separate client code for each API.

## Purpose

ReqLLM serves as the universal LLM client layer for the Jido ecosystem. It abstracts away provider-specific API differences so that higher-level packages can interact with any supported AI model through a single, consistent interface.

## Major Components

### Core API (`ReqLLM`)
High-level functions: `generate_text/3`, `stream_text/3`, `generate_object/4`, `generate_image/3`, model resolution, key management, and provider lookup.

### Streaming System
Three-component architecture: `Streaming` orchestrates flow, `StreamServer` manages state and SSE events, `StreamResponse` provides lazy token streams with early cancellation.

### Provider System
Behaviour-based provider architecture with 15+ concrete implementations: Anthropic, OpenAI, Google, Groq, OpenRouter, xAI, Amazon Bedrock, Cerebras, and more.

### Tool Calling
Function calling framework with NimbleOptions-compatible parameter schemas, automatic JSON Schema conversion, and callback execution.

### Billing & Usage
Component-based billing calculator with per-million-token cost computation and `[:req_llm, :token_usage]` telemetry events.
