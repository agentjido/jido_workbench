%{
  description: "Canonical definitions for every term used across Jido documentation and source code.",
  title: "Glossary",
  category: :docs,
  legacy_paths: ["/docs/glossary"],
  tags: [:docs, :reference],
  order: 350
}
---

Definitions match how Jido uses each term. Where a term has a broader industry meaning, the Jido-specific usage is noted.

## Core primitives

**Action** — A pure, composable unit of validated computation. Actions declare an input schema, execute a `run/2` function, and return a result map. They never perform side effects directly. See [Actions concept](/docs/concepts/actions).

**Agent** — An immutable struct with schema-validated state and a command interface. Agents are data, not processes. You pass an agent to `cmd/2` with an action, and get back a new struct plus directives. The original is unchanged. See [Agents concept](/docs/concepts/agents).

**AgentServer** — The GenServer wrapper that runs an agent struct as a long-lived OTP process. AgentServer handles signal routing, directive execution, process supervision, and lifecycle management. See [Agent Runtime concept](/docs/concepts/agent-runtime).

**Directive** — A pure description of an external effect. Actions emit directives; the runtime executes them. This separation keeps action logic deterministic and testable. Built-in types: `Emit`, `Spawn`, `Kill`, `EnqueueAction`, `RegisterAction`, `DeregisterAction`. See [Directives concept](/docs/concepts/directives).

**Signal** — A structured message envelope implementing the CloudEvents v1.0.2 specification. Signals carry events and commands through the system. Required fields include `type`, `source`, `id`, and `specversion`. See [Signals concept](/docs/concepts/signals).

## Runtime and execution

**Jido instance** — A named supervision tree created with `use Jido, otp_app: :my_app`. Each instance gets its own registry, supervisor, and configuration scope. Multiple instances can run in the same BEAM node.

**Strategy** — A pluggable execution model that controls how agents process actions. The core ships `Direct` (sequential) and `FSM` (finite state machine). `jido_ai` adds reasoning strategies like ReAct, Chain of Thought, and Tree of Thoughts. See [Strategy concept](/docs/concepts/strategy).

**Direct strategy** — The default strategy. Executes instructions sequentially in a single pass. Each instruction runs, merges results into agent state, separates directives, and moves to the next.

**cmd/2** — The core function that runs an action against an agent. Takes an agent struct and action instructions, returns `{updated_agent, directives}`. Pure — no side effects, no processes.

**Instruction** — A tuple of `{action_module, params}` passed to `cmd/2`. Multiple instructions can be batched in a single command.

## Sensors and plugins

**Sensor** — A GenServer-backed module that bridges external events into Jido's signal layer. Sensors observe sources like PubSub topics, webhooks, and timers, then transform raw events into typed signals. See [Sensors concept](/docs/concepts/sensors).

**Plugin** — A reusable package of agent functionality: actions, signal routes, state fields, and lifecycle hooks bundled into one module. Plugins validate configuration at compile time and isolate state under a dedicated key. See [Plugins concept](/docs/concepts/plugins).

## AI integration (jido_ai)

**Model alias** — A semantic atom (`:fast`, `:capable`, `:thinking`, `:reasoning`) that maps to a full provider model string. Aliases let you change models in config without touching code. See [Configuration](/docs/reference/configuration).

**ReAct** — A reasoning strategy where the agent iterates through Reason → Act → Observe loops. The LLM decides which tool to call, the runtime executes it, and results feed back into the next reasoning step.

**Chain of Thought (CoT)** — A reasoning strategy where the LLM breaks a problem into explicit intermediate steps before producing a final answer.

**Tree of Thoughts (ToT)** — A reasoning strategy that explores multiple solution branches in parallel, evaluating and pruning paths to find the best approach.

**Turn** — A single request-response cycle in an AI agent conversation. A turn may involve multiple LLM calls and tool executions internally.

**Tool** — An action module registered with an AI agent for LLM tool calling. Tools must implement `name/0`, `schema/0`, and `run/2`. Tools can be registered and unregistered at runtime.

## Infrastructure

**BEAM** — The Erlang virtual machine that runs Elixir. Provides lightweight processes, preemptive scheduling, and fault isolation. Jido uses BEAM primitives (GenServer, Supervisor, Registry) as its runtime foundation.

**OTP** — Open Telecom Platform. The framework of design patterns (supervision trees, GenServers, applications) that Erlang/Elixir uses for building reliable systems. Jido agents run inside OTP supervision trees.

**Supervision tree** — A hierarchy of OTP supervisors and workers. When a process crashes, its supervisor restarts it according to a defined strategy. Each Jido instance creates its own supervision tree.

**Registry** — Elixir's built-in process registry. Jido uses `Jido.Registry` to look up agent processes by string ID without tracking PIDs directly.

## Telemetry

**Telemetry event** — A named measurement emitted via `:telemetry.execute/3`. Jido emits events for agent commands, signal processing, directive execution, and strategy operations. See [Telemetry and observability](/docs/reference/telemetry-and-observability).

**Span** — A start/stop event pair that measures duration. Jido uses `Jido.Observe.span/3` to wrap operations and emit `[:start]` and `[:stop]` (or `[:exception]`) events automatically.

**Interestingness filtering** — Jido's telemetry system filters events at DEBUG level, only logging signals that are slow, produce directives, match configured types, or error. This reduces noise from high-frequency internal signals.

## Next steps

- [Configuration](/docs/reference/configuration) - all config keys and defaults
- [Telemetry and observability](/docs/reference/telemetry-and-observability) - event reference
- [Concepts](/docs/concepts) - deep dives into each primitive
