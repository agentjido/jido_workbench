%{
  name: "jido_ai",
  title: "Jido AI",
  version: "2.0.0",
  tagline: "LLM orchestration, reasoning strategies, and accuracy improvement for Jido agents",
  license: "Apache-2.0",
  visibility: :public,
  category: :ai,
  tier: 1,
  tags: [:ai, :llm, :reasoning, :agents],
  hex_url: "https://hex.pm/packages/jido_ai",
  hexdocs_url: "https://hexdocs.pm/jido_ai",
  github_url: "https://github.com/agentjido/jido_ai",
  github_org: "agentjido",
  github_repo: "jido_ai",
  elixir: "~> 1.17",
  ecosystem_deps: ["jido", "jido_browser"],
  key_features: [
    "Six reasoning strategies — ReAct, Chain-of-Thought, Tree-of-Thoughts, Graph-of-Thoughts, TRM, and Adaptive",
    "Multi-stage accuracy pipeline with configurable presets",
    "Self-consistency voting with majority vote, best-of-n, and weighted aggregation",
    "Search algorithms — Beam Search, MCTS, and Diverse Decoding",
    "Five verifier types for validating LLM outputs",
    "Reflection and self-refinement loops",
    "Dynamic tool registration/unregistration at runtime",
    "Async request tracking with ask/await pattern",
    "Model aliases for semantic model references",
    "Prompt evaluation framework (GEPA)",
    "Signal-driven architecture with automatic routing per strategy",
    "Security hardening — prompt injection detection, input sanitization"
  ]
}
---
## Overview

Jido AI is the AI integration layer for the Jido ecosystem, providing LLM orchestration, reasoning strategies, and research-backed accuracy improvement techniques for building intelligent agents in Elixir. Built on top of ReqLLM for multi-provider LLM access, it turns raw LLM calls into structured, reliable agent behaviors through composable strategies, accuracy pipelines, and a robust tool execution framework.

## Purpose

Jido AI serves as the intelligence layer of the Jido ecosystem. It bridges the gap between raw LLM API calls and structured, reliable agent reasoning.

## Major Components

### Reasoning Strategies
Six pluggable strategies: ReAct (tool-using agents), Chain-of-Thought, Tree-of-Thoughts, Graph-of-Thoughts, TRM (Tiny-Recursive-Model with adaptive computation), and Adaptive (automatic strategy selection).

### Accuracy Improvement Pipeline
Multi-stage pipeline with self-consistency voting, search algorithms (Beam Search, MCTS), verifiers (LLM, code execution, deterministic, static analysis, unit test), difficulty estimation, reflection/revision loops, and confidence calibration.

### Pre-Built Actions
Composable Jido Actions for LLM operations (Chat, Complete, Embed, GenerateObject), Reasoning (Analyze, Explain, Infer), Planning (Plan, Decompose, Prioritize), Orchestration (DelegateTask, SpawnChildAgent), Streaming, and Tool Calling.

### Agent Macros
Ready-to-use agent bases: ReActAgent, CoTAgent, ToTAgent, GoTAgent, TRMAgent, AdaptiveAgent, and OrchestratorAgent.

### Plugins
Composable skill bundles for LLM, Reasoning, Planning, Orchestration, Streaming, Tool Calling, and TaskSupervisor capabilities.
