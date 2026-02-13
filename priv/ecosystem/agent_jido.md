%{
  name: "agent_jido",
  title: "Agent Jido",
  version: "0.1.0",
  tagline: "Reference Phoenix application showcasing the Jido AI agent ecosystem",
  license: "Apache-2.0",
  visibility: :private,
  category: :runtime,
  tier: 3,
  tags: [:phoenix, :reference, :application, :demo],
  github_url: "https://github.com/agentjido/agent_jido",
  github_org: "agentjido",
  github_repo: "agent_jido",
  elixir: "~> 1.17",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "not yet defined",
  stub: false,
  support: :best_effort,
  limitations: [
    "Reference application — not a library, not installable as a dependency",
    "Private repository — not publicly accessible",
    "Requires extensive environment setup (PostgreSQL, API keys, etc.)",
    "Demos depend on external AI services with associated costs"
  ],
  ecosystem_deps: ["jido", "jido_action", "jido_signal", "jido_ai", "ash_jido", "req_llm"],
  key_features: [
    "Parallel sandbox execution engine (Forge) with pluggable runners and concurrency control",
    "GTD task management agent (Folio) with AI-powered inbox processing",
    "Multi-phase GitHub Issue Bot with autonomous triage and research",
    "Interactive AI chat with real-time ReAct reasoning visualization",
    "Claude Code integration for AI-powered coding sessions in sandboxed environments",
    "Ash Framework persistence with PostgreSQL, authorization, and admin UI",
    "Full authentication stack — password, magic link, API keys, email confirmation",
    "JSON:API with Swagger documentation via AshJsonApi",
    "70+ Mishka Chelekom UI components with Tailwind CSS v4",
    "Fly.io deployment with blue-green deploys and DNS clustering"
  ]
}
---
## Overview

Agent Jido is a full-stack Phoenix 1.8 application that serves as the reference implementation and showcase for the Jido AI agent ecosystem. It demonstrates how to build production-grade, agent-powered web applications by combining Phoenix LiveView for real-time UI, the Ash Framework for declarative data modeling, and the Jido agent runtime for autonomous multi-agent workflows — all in a single deployable application.

Beyond being a demo, Agent Jido is a working platform that includes a parallel sandbox execution engine (Forge), a GTD-inspired task management agent (Folio), a multi-phase GitHub Issue Bot with autonomous triage and research capabilities, and an interactive AI chat interface with full observability into the ReAct reasoning loop. It is deployed to Fly.io at jido.eboss.ai and provides both browser-based LiveView UIs and a JSON:API with Swagger documentation.

## Purpose

Agent Jido is the canonical reference application for the Jido ecosystem. Its role is threefold:

1. **Showcase** — Demonstrates real-world integration of Jido agents, sensors, signals, and actions inside a Phoenix application with Ash-backed persistence, authentication, and admin tooling.
2. **Proving ground** — Validates ecosystem packages (jido, jido_ai, jido_action, jido_signal, ash_jido) working together in a production-like environment with PostgreSQL, PubSub, and OTP supervision trees.
3. **Starter template** — Provides patterns and conventions that teams can adopt when building their own Jido-powered applications.

## Major Components

### Forge — Parallel Sandbox Execution Engine
The `AgentJido.Forge` subsystem provisions isolated container/sandbox environments (sprites), runs pluggable execution runners inside them in discrete iterations, and persists session lifecycle events for observability. Includes Shell, Workflow, ClaudeCode, and Custom runners with a global lifecycle manager enforcing concurrency limits.

### Folio — GTD Task Management Agent
An AI-powered Getting Things Done (GTD) system built entirely with Jido agents and Ash resources. Features a ReActAgent with 20+ tools covering inbox capture, clarification, action management, and project tracking.

### GitHub Integration — Webhook Sensor & Issue Bot
Multi-phase autonomous agent pipeline: CoordinatorAgent owns the lifecycle of a single issue, spawning child agents per phase — TriageAgent for classification, ResearchCoordinator fanning out to CodeSearchAgent, ReproductionAgent, RootCauseAgent, and PRSearchAgent.

### Demos
Interactive AI chat demo with streaming text display, tool call lifecycle visualization, thinking/reasoning panels, and usage metrics — powered by Claude Haiku via the ReAct reasoning strategy.
