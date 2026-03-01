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

### Action

A pure, composable unit of validated computation. Actions declare an input schema, execute a `run/2` function, and return a result map. They never perform side effects directly. See [Actions concept](/docs/concepts/actions).

### Agent

An immutable struct with schema-validated state and a command interface. Agents are data, not processes. You pass an agent to `cmd/2` with an action, and get back a new struct plus directives. The original is unchanged. See [Agents concept](/docs/concepts/agents).

### AgentServer

The GenServer wrapper that runs an agent struct as a long-lived OTP process. AgentServer handles signal routing, directive execution, process supervision, and lifecycle management. See [Agent Runtime concept](/docs/concepts/agent-runtime).

### Directive

A pure description of an external effect. Actions emit directives; the runtime executes them. This separation keeps action logic deterministic and testable. Built-in types: `Emit`, `Schedule`, `Cron`, `SpawnAgent`, `StopChild`, `Spawn`, `RunInstruction`, `Stop`, `Error`. See [Directives concept](/docs/concepts/directives).

### Instruction

A normalized work order that pairs an [Action](#action) module with its parameters, context, and options. All shorthand forms (`MyAction`, `{MyAction, params}`, full struct) normalize to `%Jido.Instruction{}` before execution.

### Plugin

A reusable package of agent functionality: actions, signal routes, state fields, and lifecycle hooks bundled into one module. Plugins validate configuration at compile time and isolate state under a dedicated key. See [Plugins concept](/docs/concepts/plugins).

### Sensor

A GenServer-backed module that bridges external events into Jido's signal layer. Sensors observe sources like PubSub topics, webhooks, and timers, then transform raw events into typed signals. See [Sensors concept](/docs/concepts/sensors).

### Signal

A structured message envelope implementing the CloudEvents v1.0.2 specification. Signals carry events and commands through the system. Required fields include `type`, `source`, `id`, and `specversion`. See [Signals concept](/docs/concepts/signals).

## Agent cognition

### Identity

A reserved first-class agent primitive stored at `agent.state[:__identity__]`. Tracks lifecycle facts including revision counter, profile (age, generation, origin), and timestamps. Updated via `Jido.Identity.evolve/2`.

### Memory

The mutable cognitive substrate stored at `agent.state[:__memory__]`. Contains named [Spaces](#memory-space) that hold current beliefs, goals, and working data. Memory represents what the agent currently knows, as opposed to [Thread](#thread), which records what happened. See [Memory concept](/docs/concepts/memory).

### Memory Space

A named partition within [Memory](#memory). Each space holds either a key-value map or an ordered list, with its own revision counter for fine-grained concurrency control. Two built-in reserved spaces: `:world` (key-value) and `:tasks` (ordered list).

### Thread

An immutable, append-only log of `Entry` structs stored at `agent.state[:__thread__]`. Records what happened during agent operation. Provider-agnostic: LLM conversation context is projected from Thread entries, never stored directly. See [Thread concept](/docs/concepts/thread).

### Thread Entry

A single record in a [Thread](#thread). Contains `id`, `seq` (monotonic), `kind` (`:message`, `:tool_call`, `:tool_result`, `:signal_in`, `:signal_out`, `:instruction_start`, `:instruction_end`, `:note`, `:error`, `:checkpoint`), `payload`, and `refs` for cross-linking.

## Execution and runtime

### Await

A synchronous coordination API for waiting on agent completion. Supports `completion/3` (single agent), `all/3` (all agents), `any/3` (first to complete), and `child/4` (named child of a parent). Agents signal completion through `state.status`, not process death.

### Chain

Sequential execution of multiple actions where each action's output merges into the params available to the next. Implemented by `Jido.Exec.Chain` and used internally when you pass a list of instructions to `cmd/2`.

### Closure

A partially applied action created by `Jido.Exec.Closure`. Pre-binds context and options, returning a function that only needs params to execute. Useful for passing configured actions to higher-order functions.

### cmd/2

The core function that runs an action against an agent. Takes an agent struct and action instructions, returns `{updated_agent, directives}`. Pure — no side effects, no processes. See [Agents concept](/docs/concepts/agents).

### Compensation

An error-recovery mechanism where an action's `on_error/4` callback is invoked when execution fails. Used for cleanup, rollback, or saga-style compensating transactions. Enabled per-action via the `compensation:` option.

### Direct strategy

The default [Strategy](#strategy). Executes instructions sequentially in a single pass. Each instruction runs, merges results into agent state, separates directives, and moves to the next.

### DirectiveExec

The protocol that dispatches directive execution. Each directive struct type implements `exec/3`, which the [AgentServer](#agentserver) calls during the drain loop. Custom directives implement this protocol to integrate with the runtime.

### Discovery

A runtime introspection system using `:persistent_term` that auto-discovers all Jido components (actions, sensors, agents, plugins) across loaded OTP applications. Each component gets a stable 8-character URL-safe slug for API access.

### Error Policy

A configurable error-handling strategy for [AgentServer](#agentserver). Options: `:log_only` (default), `:stop_on_error`, `{:emit_signal, dispatch}`, `{:max_errors, n}`, or a custom function.

### Exec

The public execution engine (`Jido.Exec`) that runs actions through a pipeline: normalize → validate → inject metadata → telemetry span → timeout budget → `run/2` → validate output → compensation on error → retry. See [Execution concept](/docs/concepts/execution).

### FSM strategy

A finite state machine [Strategy](#strategy) that enforces valid state transitions. Useful for workflows with well-defined phases — approval pipelines, order processing, onboarding flows. State is stored in `agent.state.__strategy__`.

### InstanceManager

A keyed singleton registry pattern. One agent per logical key (user session, game room, conversation ID). Supports lookup-or-start, automatic idle timeout, attachment tracking, and optional hibernate-on-idle before stop.

### Jido instance

A named supervision tree created with `use Jido, otp_app: :my_app`. Each instance gets its own registry, supervisor, task supervisor, and configuration scope. Multiple instances can run in the same BEAM node.

### Open validation

Jido's validation model where only fields declared in a schema are validated — undeclared fields pass through untouched. Intentional for action composition: intermediate actions don't reject data they don't use.

### Plan

A DAG-based workflow definition using `Jido.Plan`. Nodes are [Instructions](#instruction) with declared dependencies. Topological sorting produces parallel execution phases where independent steps can run concurrently.

### Retry

Automatic re-execution of failed actions with exponential backoff. Configured via `opts: [retry: true, max_retries: 3]` on execution. Implemented by `Jido.Exec.Retry`.

### StateOp

An internal state mutation operation applied during strategy execution. Types: `SetState` (deep merge), `ReplaceState`, `DeleteKeys`, `SetPath`, `DeletePath`. StateOps are separated from [Directives](#directive) — StateOps modify the agent struct, directives go to the runtime.

### Strategy

A pluggable execution model that controls how agents process actions. The core ships `Direct` and `FSM`. `jido_ai` adds reasoning strategies. `jido_behaviortree` adds behavior tree execution. Implements the `Jido.Agent.Strategy` behaviour. See [Strategy concept](/docs/concepts/strategy).

### WorkerPool

A Poolboy-backed agent pool. Pre-warmed agents are checked out for a transaction, then returned. Configured via `agent_pools:` in `use Jido`. Supports `with_agent/4` (transaction), `call/4`, `cast/4`, and pool health stats.

## Signals and routing

### Bus

An in-memory GenServer-based pub/sub hub (`Jido.Signal.Bus`). Supports topic subscriptions with pattern matching, signal logging with replay, snapshots, partitioning for horizontal scaling, and [Dead Letter Queue](#dead-letter-queue) management.

### Circuit breaker

Fault isolation for external dispatch targets (HTTP, webhooks). Uses the `:fuse` library: 5 failures in 10 seconds opens the circuit; auto-resets after 30 seconds. Prevents cascading failures from unreachable endpoints.

### CloudEvents

The industry-standard structured event format (v1.0.2) that [Signals](#signal) implement. Defines required fields (`specversion`, `id`, `source`, `type`) and extension mechanisms. See [cloudevents.io](https://cloudevents.io/).

### Dead Letter Queue

A holding area for signals that exhaust retry attempts in a [Persistent Subscription](#persistent-subscription). Signals in the DLQ can be inspected via `dlq_entries/2`, redriven via `redrive_dlq/3`, or cleared.

### Dispatch

The adapter-based signal delivery system (`Jido.Signal.Dispatch`). Built-in adapters: `:pid`, `:named`, `:bus`, `:pubsub` (Phoenix.PubSub), `:logger`, `:console`, `:http`, `:webhook` (HMAC-signed), `:noop`.

### Journal

A causality graph (`Jido.Signal.Journal`) that tracks directed cause-effect relationships between signals. Supports chain tracing forward (effects) and backward (causes), conversation grouping by subject, and time-range queries.

### Middleware

Cross-cutting hooks on the [Bus](#bus) that run before/after signal publish and dispatch. Four hook points: `before_publish`, `after_publish`, `before_dispatch`, `after_dispatch`. Timeout-protected (default 100ms).

### Persistent Subscription

A durable [Bus](#bus) subscription with at-least-once delivery guarantees. Tracks in-flight signals, manages a pending queue with backpressure, retries failed deliveries, and checkpoints progress for restart recovery.

### Signal Extension

A CloudEvents-compliant mechanism for attaching custom metadata to signals via `Jido.Signal.Ext`. Extensions declare a namespace and schema, and are flattened/inflated during serialization.

### Signal Router

A trie-based pattern matching engine (`Jido.Signal.Router`) that maps signal types to actions. Supports exact matches, single-segment wildcards (`*`), and multi-level wildcards (`**`). Routes have priorities from -100 to +100.

### Signal Trace

W3C `traceparent`-compatible distributed tracing stored in the `"correlation"` signal extension. Propagates `trace_id`, `span_id`, `parent_span_id`, and `causation_id` across signal chains.

### UUID v7

The ID format used for signal identifiers. Timestamp-based (first 48 bits = Unix ms), monotonically increasing, with a 12-bit sequence counter. Enables chronological sorting, efficient database indexing, and timestamp extraction from the ID itself.

## Persistence and storage

### Checkpoint

A point-in-time snapshot of an agent's state, created during [hibernate](#hibernate). Contains the full agent state plus a thread pointer (id + rev), but never the full thread data. Stored via the [Storage](#storage) behaviour.

### Hibernate

The process of persisting an agent's state to storage before shutdown. Flushes the thread journal, creates a [Checkpoint](#checkpoint), and calls the optional `agent_module.checkpoint/2` hook. Invoked via `Jido.Persist.hibernate/2`.

### Storage

A behaviour (`Jido.Storage`) with six callbacks for checkpoint and thread persistence. Built-in adapters: `Jido.Storage.ETS` (ephemeral, dev/test) and `Jido.Storage.File` (file-based). Supports optimistic concurrency via `:expected_rev` on thread operations.

### Thaw

The process of restoring an agent from a [Checkpoint](#checkpoint). Loads the checkpoint, calls the optional `agent_module.restore/2` hook, rehydrates the thread by pointer, and verifies revision consistency. Invoked via `Jido.Persist.thaw/3`.

## AI integration (jido_ai)

### Adaptive strategy

A meta-[Strategy](#strategy) that analyzes prompt complexity and selects the appropriate reasoning strategy at runtime. Delegates to CoD, CoT, ReAct, ToT, GoT, or TRM based on configurable complexity thresholds.

### Algorithm of Thoughts (AoT)

A reasoning strategy that mimics algorithmic search (DFS or BFS) in a single LLM call. Produces structured results including whether a solution was found, operations considered, and backtracking steps.

### Chain of Draft (CoD)

A reasoning strategy like [CoT](#chain-of-thought-cot) but prompting the model to keep each draft step to ≤5 words. Optimizes for low-token reasoning with reduced latency and cost.

### Chain of Thought (CoT)

A reasoning strategy where the LLM breaks a problem into explicit intermediate steps before producing a final answer. Good for math, logic, and structured analysis.

### Effects Policy

A security mechanism that controls which [Directives](#directive) emitted by tool execution are allowed to propagate into the agent. Modes: `:allow_list` (default), `:allow_all`, `:deny_all`. Strategy-level policy can only narrow, never broaden, the agent-level policy.

### Graph of Thoughts (GoT)

A reasoning strategy that explores graph-structured thought nodes with edges representing relationships. Synthesizes across perspectives rather than selecting the best branch, using generation, connection-finding, and aggregation prompts.

### Model alias

A semantic atom (`:fast`, `:capable`, `:thinking`, `:reasoning`, `:planning`, `:image`, `:embedding`) that maps to a full [Model spec](#model-spec) string. Aliases let you change models in config without touching code. See [Configuration](/docs/reference/configuration).

### Model routing

An AI plugin that automatically selects model aliases by signal type when no explicit model is specified. For example, `chat.message` signals default to `:capable` while `reasoning.*.run` signals default to `:reasoning`.

### Prompt injection detection

A [Policy plugin](#policy-plugin) feature that scans incoming queries for injection patterns (role-playing attacks, "ignore previous instructions", base64 encoding requests). In `:enforce` mode, violating queries are rewritten to error signals.

### ReAct

The flagship reasoning strategy where the agent iterates through Reason → Act → Observe loops. The LLM decides which tool to call, the runtime executes it, and results feed back into the next reasoning step. Supports checkpoint tokens for caller-owned continuation.

### Request

A tracked async operation in `jido_ai` (`Jido.AI.Request`). The `ask/await` pattern: `ask/3` casts a query signal and returns a `Request.Handle` with a correlation ID; `await/2` polls for completion. Solves concurrent request tracking.

### Tool

An [Action](#action) module registered with an AI agent for LLM tool calling. Tools must implement `name/0`, `description/0`, and `schema/0`. The [ToolAdapter](#tooladapter) converts actions to LLM-compatible tool definitions.

### ToolAdapter

The bridge between Jido [Actions](#action) and LLM tool-calling interfaces (`Jido.AI.ToolAdapter`). Converts action modules to `ReqLLM.Tool` structs with noop callbacks — actual execution happens through the Jido runtime, not inline during the LLM call.

### TRM

Tiny Recursive Model. A reasoning strategy using iterative refinement with a supervisor/improver pattern. The model reasons, a supervisor evaluates, and improvements are applied recursively until a confidence threshold is met.

### Tree of Thoughts (ToT)

A reasoning strategy that explores multiple thought branches, evaluates each with scoring, and selects the best. Supports configurable branching factors, depth limits, traversal strategies, and convergence detection.

### Turn

A single request-response cycle in an AI agent conversation. A turn may involve multiple LLM calls and tool executions internally. Represented by `Jido.AI.Turn` with fields for type (`:tool_calls` or `:final_answer`), text, thinking content, and usage.

## Browser automation (jido_browser)

### Browser Adapter

A behaviour (`JidoBrowser.Adapter`) that defines the contract for browser automation backends. Two built-in implementations: [Vibium](#vibium) (Chrome via WebDriver BiDi) and Web (Firefox via chrismccord/web). All communication happens via Erlang Ports.

### Browser Session

A validated struct (`JidoBrowser.Session`) representing an active browser connection. Every mutating operation returns an updated session — callers thread the session forward to track state changes like `current_url`. No hidden process state.

### Snapshot

An LLM-optimized browser action that executes in-browser JavaScript to return a structured map of `{url, title, meta, content, links, forms, headings}`. Purpose-built for agent reasoning loops where structured page data is more useful than raw HTML.

### Vibium

The default browser automation backend. A Go binary implementing the WebDriver BiDi protocol that manages Chrome/Chromium automatically. Installed via npm (`npm install -g vibium`).

## LLM infrastructure (req_llm, llm_db)

### Context

A conversation container (`ReqLLM.Context`) that holds an ordered list of messages. Implements `Enumerable` and `Collectable`. Response objects include an updated context for multi-turn conversations.

### Embedding

A vector representation of text produced by an embedding model. Generated via `ReqLLM.embed/3`. Used for semantic search, retrieval, and similarity comparisons.

### LLMDB

A read-only, offline-capable model metadata catalog (`llm_db` package). Ships a pre-built snapshot of 45+ providers and 665+ models. All runtime reads are O(1) via `:persistent_term`. See [ReqLLM and LLMDB reference](/docs/reference/req-llm-and-llmdb).

### Model spec

A string identifying a specific provider and model combination. Two interchangeable formats: `"openai:gpt-4o"` (colon) and `"gpt-4o@openai"` (at-sign, filesystem-safe). Parsed by `LLMDB.parse/1`.

### Provider

A module implementing the `ReqLLM.Provider` behaviour that handles request preparation, body encoding, response decoding, and streaming for a specific LLM service. Built-in providers include Anthropic, OpenAI, Google, Amazon Bedrock, Azure, Groq, xAI, and others.

### ReqLLM

The provider-agnostic LLM HTTP client (`req_llm` package) built on Req. Provides `generate_text/3`, `stream_text/3`, `generate_object/4`, and `embed/3`. Uses [LLMDB](#llmdb) for model/provider resolution and cost calculation. See [ReqLLM and LLMDB reference](/docs/reference/req-llm-and-llmdb).

### StreamResponse

A streaming LLM response (`ReqLLM.StreamResponse`) that separates the token stream from metadata collection. Contains a lazy `Stream` of chunks for real-time processing, a concurrent metadata handle for usage/finish_reason, and a cancel function.

### Structured generation

Constrained LLM output using `ReqLLM.generate_object/4`. Compiles a NimbleOptions or Zoi schema into JSON Schema, then drives provider-specific structured output mechanisms (tool calling or `json_schema` mode) to guarantee type-safe responses.

## Observability

### Debug mode

A runtime observability toggle (`Jido.Debug`) that controls verbosity across an entire [Jido instance](#jido-instance). Three levels: `:off` (production), `:on` (developer-friendly), `:verbose` (maximum). Stored in `:persistent_term` for fast reads. Distinct from Elixir's Logger level.

### Interestingness filtering

Jido's telemetry system filters events at DEBUG level, only logging signals that are slow, produce directives, match configured types, or error. Reduces noise from high-frequency internal signals.

### Span

A start/stop event pair that measures duration. Jido uses `Jido.Observe.span/3` to wrap operations and emit `[:start]` and `[:stop]` (or `[:exception]`) events automatically.

### Telemetry event

A named measurement emitted via `:telemetry.execute/3`. Jido emits events for agent commands, signal processing, directive execution, strategy operations, and queue overflows. See [Telemetry and observability](/docs/reference/telemetry-and-observability).

### Tracer

A behaviour (`Jido.Observe.Tracer`) for integrating distributed tracing systems like OpenTelemetry. Implements `span_start/2`, `span_stop/2`, and `span_exception/4`. The extension point for production tracing backends.

### Tracing Context

Per-process trace context (`Jido.Tracing.Context`) that propagates `trace_id`, `span_id`, `parent_span_id`, and `causation_id` through signal processing. Automatically merged into all `Jido.Observe` spans.

## Infrastructure

### BEAM

The Erlang virtual machine that runs Elixir. Provides lightweight processes, preemptive scheduling, and fault isolation. Jido uses BEAM primitives (GenServer, Supervisor, Registry) as its runtime foundation.

### OTP

Open Telecom Platform. The framework of design patterns (supervision trees, GenServers, applications) that Erlang/Elixir uses for building reliable systems. Jido agents run inside OTP supervision trees.

### Registry

Elixir's built-in process registry. Jido uses `Jido.Registry` to look up agent processes by string ID without tracking PIDs directly. Each [Jido instance](#jido-instance) has its own registry.

### Splode

The error library used by Jido for structured error hierarchies. Provides composable error classes, structured exception structs with typed fields, and error aggregation. Used across `jido`, `jido_action`, `jido_signal`, and `jido_browser`.

### Supervision tree

A hierarchy of OTP supervisors and workers. When a process crashes, its supervisor restarts it according to a defined strategy. Each [Jido instance](#jido-instance) creates its own supervision tree.

### Zoi

The schema validation library used throughout Jido for defining typed data contracts. Supports objects, strings, integers, floats, atoms, lists, and nested types. Schemas serve dual duty: runtime validation and JSON Schema generation for LLM tool definitions.

## Next steps

- [Configuration](/docs/reference/configuration) - all config keys and defaults
- [Telemetry and observability](/docs/reference/telemetry-and-observability) - event reference
- [ReqLLM and LLMDB](/docs/reference/req-llm-and-llmdb) - LLM infrastructure reference
- [Concepts](/docs/concepts) - deep dives into each primitive
