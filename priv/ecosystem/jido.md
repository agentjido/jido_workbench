%{
  name: "jido",
  title: "Jido",
  version: "2.0.0-rc.4",
  tagline: "Core agent framework for building autonomous, multi-agent systems in Elixir",
  license: "Apache-2.0",
  visibility: :public,
  category: :core,
  tier: 1,
  tags: [:agents, :otp, :framework, :beam],
  hex_url: "https://hex.pm/packages/jido",
  hexdocs_url: "https://hexdocs.pm/jido",
  github_url: "https://github.com/agentjido/jido",
  github_org: "agentjido",
  github_repo: "jido",
  elixir: "~> 1.17",
  ecosystem_deps: ["jido_action", "jido_signal"],
  landing_major_components: [
    %{
      name: "Jido.Agent",
      summary: "Defines the core immutable agent contract and cmd/2 lifecycle.",
      docs_url: "https://hexdocs.pm/jido/Jido.Agent.html"
    },
    %{
      name: "Jido.AgentServer",
      summary: "OTP runtime wrapper for production execution, routing, and supervision.",
      docs_url: "https://hexdocs.pm/jido/Jido.AgentServer.html"
    },
    %{
      name: "Jido.Plan",
      summary: "DAG planning primitives for dependency-aware multi-step execution.",
      docs_url: "https://hexdocs.pm/jido/Jido.Plan.html"
    },
    %{
      name: "Jido.Plugin",
      summary: "Composable extension mechanism for capabilities, hooks, and state.",
      docs_url: "https://hexdocs.pm/jido/Jido.Plugin.html"
    },
    %{
      name: "Jido.Agent.Directive",
      summary: "Typed effect contracts emitted by cmd/2 and executed by runtimes.",
      docs_url: "https://hexdocs.pm/jido/Jido.Agent.Directive.html"
    }
  ],
  key_features: [
    "Pure functional agent architecture — agents are immutable data structures",
    "Elm/Redux-inspired cmd/2 contract — actions in, updated agent + directives out",
    "Schema-validated state with NimbleOptions or Zoi",
    "Directive-based effect system — side effects described, not performed",
    "Pluggable execution strategies (Direct, FSM, custom)",
    "Composable plugin system with isolated state and lifecycle hooks",
    "OTP-native runtime with GenServer-based AgentServer",
    "Parent-child agent hierarchies with lifecycle monitoring",
    "Signal-driven communication with configurable routing",
    "Append-only interaction threads with journal-backed persistence",
    "Agent memory system with named spaces",
    "Hibernate/thaw persistence for checkpoint and restore",
    "Pre-warmed worker pools via Poolboy",
    "Per-agent cron scheduling",
    "Automatic component discovery via persistent_term",
    "Testable without processes — pure cmd/2 enables unit testing"
  ]
}
---
## Overview

Jido (自動, Japanese for "automatic") is the core agent framework for building autonomous, multi-agent systems in Elixir. It provides a pure functional agent architecture inspired by Elm/Redux where agents are immutable data structures updated through a single `cmd/2` operation — actions transform state, directives describe side effects, and an OTP-powered runtime executes everything in production. This separation of pure decision logic from effectful execution gives developers deterministic, testable agent behavior with the full power of the BEAM underneath.

As the foundation of the Jido ecosystem, this package formalizes the patterns that raw OTP leaves ad-hoc: standardized signal envelopes replace custom message shapes, reusable actions replace business logic scattered across GenServer callbacks, typed directives replace implicit effects, and built-in parent-child hierarchies replace custom child tracking. The result is a production-grade framework for building single agents, cooperating multi-agent workflows, and autonomous systems that can be reasoned about, tested without processes, and deployed with confidence.

## Purpose

Jido is the **core package** of the Jido ecosystem. It defines the Agent behaviour, the `cmd/2` contract, the directive system, execution strategies, the plugin architecture, the OTP runtime (AgentServer), and all supporting infrastructure (persistence, observability, scheduling, discovery). Every other package in the ecosystem — `jido_action`, `jido_signal`, `jido_ai` — extends or builds upon the primitives defined here.

## Major Components

### Agent (`Jido.Agent`)
The central abstraction. Agents are immutable structs with schema-validated state, updated exclusively through the `cmd/2` function. Accepts actions as modules, `{Module, params}` tuples, `%Instruction{}` structs, or lists of any of these. Returns `{updated_agent, directives}` — the agent is always fully updated and directives are external effect descriptions only. Supports lifecycle hooks (`on_before_cmd/2`, `on_after_cmd/3`).

### AgentServer (`Jido.AgentServer`)
GenServer-based OTP runtime that wraps an Agent for production deployment. Owns signal routing, executes directives through a non-blocking internal queue with drain loop, manages parent-child agent hierarchies with lifecycle monitoring, and provides sync (`call/3`) and async (`cast/2`) signal processing.

### Strategies (`Jido.Agent.Strategy`)
Pluggable execution strategies that control how `cmd/2` processes actions:
- **Direct** — Immediate sequential execution (default)
- **FSM** — Finite state machine for state-driven workflows with transition guards

### Plugins (`Jido.Plugin`)
Composable capability modules that extend agents with reusable functionality. Each plugin encapsulates actions, schema-validated state, configuration, signal routing rules, lifecycle hooks, optional child processes, and cron schedules.

### Directives (`Jido.Agent.Directive`)
Typed effect descriptions emitted by `cmd/2` for the runtime to execute: Emit, Error, Spawn, SpawnAgent, StopChild, Schedule, Stop, Cron/CronCancel.

### Sensors (`Jido.Sensor`)
Pure behaviour modules that transform external events into Jido Signals. Stateless with `init/2` and `handle_event/2` callbacks.

### Thread (`Jido.Thread`)
Append-only log of interaction entries — the canonical record of "what happened" in a conversation or workflow.

### Memory (`Jido.Memory`)
An agent's mutable cognitive substrate organized as named spaces (world, tasks, custom).

### Persistence (`Jido.Persist`, `Jido.Storage`)
Hibernate/thaw lifecycle for agents with thread support and storage adapter behaviour.

### Observability (`Jido.Observe`, `Jido.Telemetry`)
Unified observability façade wrapping `:telemetry` events with span-based tracing.

### Discovery (`Jido.Discovery`)
Fast, persistent catalog of Jido components using `:persistent_term`.
