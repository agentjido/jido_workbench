%{
  name: "jido_flame",
  title: "Jido FLAME",
  version: "0.1.0",
  tagline: "Distributed agent compute on Fly.io via FLAME with parent-child hierarchy preservation",
  license: "Apache-2.0",
  visibility: :private,
  category: :runtime,
  tier: 2,
  tags: [:flame, :distributed, :fly_io, :scaling, :remote],
  github_url: "https://github.com/agentjido/jido_flame",
  github_org: "agentjido",
  github_repo: "jido_flame",
  maturity: :experimental,
  hex_status: "unreleased",
  api_stability: "unstable — expect breaking changes",
  stub: false,
  support: :best_effort,
  limitations: [
    "Not published to Hex — available only via GitHub dependency",
    "Private repository — not publicly accessible",
    "Requires Fly.io infrastructure for production use",
    "FLAME library integration is tightly version-coupled"
  ],
  ecosystem_deps: ["jido", "jido_signal"],
  key_features: [
    "Elastic agent spawning on Fly.io with automatic idle shutdown",
    "Owner Proxy Pattern protecting remote work from parent agent restarts",
    "Full parent-child hierarchy across distributed Erlang nodes",
    "Cross-node signal communication via emit_to_parent",
    "Directive-based architecture — RemoteCall, RemoteCast, SpawnRemoteAgent, PlaceRemoteChild, StopRemoteAgent",
    "Drop-in Skill for instant FLAME capabilities on any agent",
    "LocalBackend for seamless local development and testing",
    "Registry-based reconnection after supervision restarts",
    "Automatic CloudEvents signals for agent lifecycle events",
    "Diagnostic tooling via mix jido.flame.doctor"
  ]
}
---
## Overview

JidoFlame bridges FLAME (Fleeting Lambda Application for Modular Execution) with Jido's directive-based agent architecture, enabling Jido agents to spawn child agents and execute functions on remote Fly.io machines. It provides a seamless integration layer that preserves Jido's parent-child hierarchy, signal communication, and supervision guarantees across distributed Erlang nodes — turning ephemeral cloud machines into elastic compute for your agent workloads.

At its core, JidoFlame solves a hard problem: FLAME links the calling process to the remote child, so if the caller restarts, remote work dies. JidoFlame introduces the Owner Pattern — dedicated proxy processes that own FLAME links and survive agent restarts — decoupling agent lifetime from remote work lifetime while maintaining full observability and communication.

## Purpose

JidoFlame is the distributed compute layer for the Jido ecosystem. It enables agents to elastically scale workloads across Fly.io machines — spawning remote child agents, executing remote functions, and placing arbitrary child processes on ephemeral runners — all while maintaining Jido's signal-based communication and parent-child hierarchy semantics.

## Major Components

### Core
Main API module, Owner GenServer implementing the Owner Proxy Pattern, AgentRegistry mapping logical agent IDs to PIDs, and ChildRegistry mapping agent/tag pairs to Owner PIDs.

### Directives
Pure data structs describing FLAME operations: RemoteCall (synchronous), RemoteCast (fire-and-forget), SpawnRemoteAgent (with Owner pattern), PlaceRemoteChild (generic OTP process), and StopRemoteAgent (coordinated shutdown).

### Actions
Jido.Action wrappers for each directive type, making FLAME operations composable within Jido's action/skill system.

### Runtime & Infrastructure
DirectiveExec execution engine, Skill bundle for drop-in FLAME capabilities, Remote helper for code running on FLAME nodes, and structured error handling via Splode.
