%{
  name: "jido_ai",
  title: "Jido AI",
  version: "2.0.0",
  tagline: "LLM orchestration, reasoning strategies, and accuracy improvement for Jido agents",
  graph_label: "agent intelligence",
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
  maturity: :beta,
  hex_status: "0.5.2",
  api_stability: "unstable — major rewrite in progress for 2.0, expect breaking changes",
  stub: false,
  support: :maintained,
  limitations: [
    "Published Hex version (0.5.2) is significantly behind the current GitHub main branch",
    "Reasoning strategies are implemented but not all have production-grade test coverage",
    "Accuracy pipeline presets are experimental and may change"
  ],
  ecosystem_deps: ["jido", "jido_browser", "req_llm"],
  landing_summary: "Jido AI turns raw LLM calls into structured agent intelligence with strategy-driven reasoning, tool use, and accuracy controls.",
  landing_cliff_notes: [
    "Start with a single ask/await workflow, then scale to orchestrated multi-agent reasoning.",
    "Reasoning strategies (ReAct, CoT, ToT, GoT, TRM, Adaptive) let you tune cost vs quality.",
    "Accuracy pipeline layers verification, reflection, and self-consistency on top of model outputs.",
    "Integrates directly with jido runtime, req_llm providers, and jido_browser tool execution.",
    "Designed for production reliability with async tracking, model aliases, and signal-driven orchestration."
  ],
  landing_important_packages: [
    %{id: "jido", reason: "Agent runtime, lifecycle, directives, and orchestration primitives."},
    %{id: "req_llm", reason: "Provider abstraction and transport for model requests."},
    %{id: "jido_browser", reason: "High-value agent tools for browser automation workflows."},
    %{id: "jido_action", reason: "Typed action/tool contract that powers composable capabilities."}
  ],
  landing_module_map: %{
    title: "HOW MODULES FIT TOGETHER",
    rows: [
      %{
        label: "Interface",
        nodes: [
          %{id: "jido_ai", label: "Ask/Await API", note: "Entry point for intelligent task execution"},
          %{id: "jido", label: "Agent Runtime", note: "Hosts agents, directives, and execution loops"}
        ]
      },
      %{
        label: "Reasoning Core",
        nodes: [
          %{id: "jido_ai", label: "Strategies", note: "ReAct, CoT, ToT, GoT, TRM, Adaptive"},
          %{id: "jido_ai", label: "Accuracy Pipeline", note: "Verify, reflect, and improve responses"}
        ]
      },
      %{
        label: "Model + Tools",
        nodes: [
          %{id: "req_llm", label: "ReqLLM", note: "Provider adapters and model invocation"},
          %{id: "jido_browser", label: "Tool Execution", note: "Browser actions for grounded workflows"},
          %{id: "jido_action", label: "Action Contract", note: "Composable typed capabilities"}
        ]
      }
    ],
    edges: [
      %{from: "Ask/Await API", to: "Strategies", label: "select strategy"},
      %{from: "Strategies", to: "Accuracy Pipeline", label: "produce and score candidates"},
      %{from: "Strategies", to: "ReqLLM", label: "call models"},
      %{from: "Strategies", to: "Tool Execution", label: "invoke tools"},
      %{from: "Tool Execution", to: "Action Contract", label: "typed actions"},
      %{from: "Ask/Await API", to: "Agent Runtime", label: "run inside agents"}
    ]
  },
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
