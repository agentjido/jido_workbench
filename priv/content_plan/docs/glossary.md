%{
  title: "Glossary",
  order: 40,
  purpose: "Establish canonical definitions for every Jido-specific term so that docs, marketing, and code all use consistent language",
  audience: :beginner,
  content_type: :reference,
  learning_outcomes: [
    "Use Jido terminology accurately and consistently",
    "Distinguish between similar concepts (e.g., Action vs Instruction, Signal vs Directive)",
    "Apply correct capitalization rules for Jido terms in prose and code"
  ],
  repos: ["jido", "jido_action", "jido_signal"],
  source_modules: [
    "Jido.Agent",
    "Jido.Action",
    "Jido.Signal",
    "Jido.Agent.Directive",
    "Jido.Agent.Strategy",
    "Jido.AgentServer",
    "Jido.Plugin",
    "Jido.Sensor",
    "Jido.Instruction",
    "Jido.Plan",
    "Jido.Scheduler",
    "Jido.Observe",
    "Jido.Discovery"
  ],
  source_files: [
    "lib/jido/agent.ex",
    "lib/jido/action.ex",
    "lib/jido/signal.ex",
    "lib/jido/agent/directive.ex",
    "lib/jido/agent/strategy.ex",
    "lib/jido/agent_server.ex",
    "lib/jido/plugin.ex",
    "lib/jido/sensor.ex",
    "lib/jido/agent/schema.ex"
  ],
  status: :draft,
  priority: :high,
  prerequisites: [],
  related: [
    "docs/key-concepts",
    "docs/agents",
    "docs/actions",
    "docs/signals",
    "docs/directives",
    "docs/plugins"
  ],
  ecosystem_packages: ["jido", "jido_action", "jido_signal"],
  destination_route: "/docs/glossary",
  destination_collection: :pages,
  tags: [:docs, :foundation, :terminology, :reference]
}
---
## Canonical glossary

This glossary defines every Jido-specific term used across documentation, marketing copy, and in-code documentation. When a term appears in any Jido content, its meaning and capitalization should match what is listed here.

### Capitalization rules

Capitalize Jido-specific terms (Agent, Action, Signal, Directive, Strategy, Plugin, Sensor, Instruction, Plan) when referring to the framework concept. Use lowercase when the word is used in a general sense unrelated to Jido. In code blocks and module names, follow Elixir conventions (`Jido.Agent`, `Jido.Action`).

---

### Agent

An Agent is an immutable data structure that holds state and can be updated via commands. Agents are defined with `use Jido.Agent` and expose a single core operation — `cmd/2` — which accepts Actions and returns a tuple of `{updated_agent, directives}`. Agents are purely functional: they never execute side effects directly. All external effects are described as Directives for the runtime to handle. Agents can declare a state schema (via Zoi), attach Plugins for reusable capabilities, and select a Strategy to control how Actions execute within `cmd/2`.

**Use "Agent"** when referring to a `Jido.Agent` struct or module. Use lowercase "agent" for the general AI-agent concept or when discussing agents across frameworks. **Avoid** using "bot", "worker", or "actor" as synonyms for a Jido Agent.

**Related:** [Action](#action), [Directive](#directive), [Strategy](#strategy), [Plugin](#plugin), [AgentServer](#agentserver)

---

### Action

An Action is a discrete, composable unit of functionality defined with `use Jido.Action`. Each Action declares a parameter schema for compile-time validation, implements a `run/2` callback containing its logic, and returns either `{:ok, result_map}` or `{:error, reason}`. Actions can perform side effects (HTTP calls, database writes) inside `run/2`, but their inputs and outputs are always validated maps. Actions are the building blocks that Agents compose via `cmd/2` — you can pass a single Action, a tuple of `{Action, params}`, an Instruction, or a list of any of these. Actions can also be converted to LLM-compatible tool definitions for AI tool-calling workflows.

**Use "Action"** when referring to a module that implements `Jido.Action`. **Avoid** "task", "step", or "function" as synonyms — use "Action" to be precise about the validated, composable contract.

**Related:** [Instruction](#instruction), [Plan](#plan), [Agent](#agent)

---

### Signal

A Signal is a typed message envelope that implements the CloudEvents v1.0.2 specification. Signals are the universal message format in Jido — every event, command, and notification flows through the system as a Signal. Each Signal carries a `type` (e.g., `"chat.message.received"`), a `source`, a `data` payload, and extensible metadata for traceability. Signals are defined in the `jido_signal` package and are routed by AgentServer to the appropriate Action via signal routes. Signals never modify Agent state directly; they trigger `cmd/2` calls that produce state changes and Directives.

**Use "Signal"** when referring to a `Jido.Signal` struct or the routing/dispatch mechanism. **Avoid** "event" or "message" as synonyms in Jido-specific docs — those are general terms. A Signal is specifically a CloudEvents-compliant envelope.

**Related:** [AgentServer](#agentserver), [Directive](#directive), [Sensor](#sensor)

---

### Directive

A Directive is a pure data description of an external effect that an Agent or Strategy emits from `cmd/2`. Directives are bare structs — never tuple-wrapped — and the Agent never executes them. The runtime (AgentServer) interprets and executes Directives via a drain loop. Built-in Directive types include `Emit` (dispatch a Signal), `Error` (signal an error), `Spawn` (start a BEAM process), `SpawnAgent` (start a child Agent with hierarchy tracking), `StopChild` (stop a tracked child), `Schedule` (deliver a delayed message), and `Stop` (terminate the Agent process). External packages can define custom Directive types by implementing the `DirectiveExec` protocol.

**Use "Directive"** when referring to effect descriptions returned from `cmd/2`. **Avoid** "command", "side effect", or "event" as synonyms. Directives are explicitly *not* commands — they are descriptions of effects for the runtime to carry out.

**Related:** [Agent](#agent), [AgentServer](#agentserver), [Signal](#signal), [Strategy](#strategy)

---

### Strategy

A Strategy controls how Actions execute within `cmd/2`. It implements the `Jido.Agent.Strategy` behaviour with a required `cmd/3` callback and optional `init/2`, `tick/2`, and `snapshot/2` callbacks. The default Strategy is `Jido.Agent.Strategy.Direct`, which executes Actions immediately and synchronously. Advanced Strategies can implement behavior trees, finite state machines, LLM chains of thought, or other execution patterns. Strategies expose their internal state through `snapshot/2`, which returns a `Strategy.Snapshot` struct, so callers never need to inspect Strategy internals. Strategies can also define `signal_routes/1` to map Signal types to Actions within AgentServer.

**Use "Strategy"** when referring to an execution model plugged into an Agent via `use Jido.Agent, strategy: ...`. **Avoid** "executor", "runner", or "engine" as synonyms.

**Related:** [Agent](#agent), [Action](#action), [AgentServer](#agentserver)

---

### AgentServer

AgentServer (`Jido.AgentServer`) is the GenServer runtime that bridges pure Agent logic with the effectful outside world. While Agents "think" (pure decision logic via `cmd/2`), AgentServer "acts" by executing the Directives they emit. Each AgentServer is a single GenServer process started under `Jido.AgentSupervisor` (a DynamicSupervisor), with registry-based naming via `Jido.Registry`. AgentServer owns Signal routing: incoming Signals are matched to Actions via Strategy-defined signal routes or a default mapping, then passed to `cmd/2`. The resulting Directives are queued and drained in a non-blocking loop.

**Use "AgentServer"** (one word, capital A capital S) when referring to the runtime process. Use "runtime" (lowercase) as a general shorthand for the operational layer. **Avoid** "server", "process", or "worker" as standalone synonyms.

**Related:** [Agent](#agent), [Directive](#directive), [Signal](#signal), [Supervision](#supervision)

---

### Plugin

A Plugin is a composable capability module that attaches to an Agent. Defined with `use Jido.Plugin`, each Plugin encapsulates a set of Actions, a state schema scoped under a `state_key`, optional configuration schema, Signal routing rules, lifecycle hooks, and child process specifications. Plugins follow a defined lifecycle: declared at compile time in the Agent's `plugins:` option, initialized via `mount/2` during `Agent.new/1`, child processes started during `AgentServer.init/1`, and Signal handling via `handle_signal/2` before routing. Plugins enable reusable capability packs — for example, a chat Plugin that bundles message Actions, conversation state, and signal routes under a single module.

**Use "Plugin"** when referring to a module that implements `Jido.Plugin`. **Avoid** "extension", "middleware", or "mixin" as synonyms.

**Related:** [Agent](#agent), [Action](#action), [Sensor](#sensor)

---

### Sensor

A Sensor is a stateless behaviour module that transforms external events into Signals. Defined with `use Jido.Sensor`, a Sensor implements `init/2` to set up initial state from configuration and `handle_event/2` to process incoming events and emit Signals. Sensors do not execute themselves — they are run by a separate SensorServer (a GenServer runtime, analogous to how AgentServer runs Agents). Sensors can return directives like `{:schedule, interval}` to request polling, `{:subscribe, topic}` to listen to event sources, or `{:emit, signal}` to dispatch Signals immediately.

**Use "Sensor"** when referring to a module that implements `Jido.Sensor`. **Avoid** "listener", "watcher", or "monitor" as synonyms in Jido-specific docs.

**Related:** [Signal](#signal), [AgentServer](#agentserver), [Plugin](#plugin)

---

### Instruction

An Instruction wraps an Action module with everything it needs to execute: the Action to perform, parameters, execution context, and runtime options. Think of Instructions as "work orders" — they tell an Agent exactly what to do and how. Instructions can be created explicitly as `%Jido.Instruction{}` structs or implicitly from shorthand forms accepted by `cmd/2`: a bare Action module (`MyAction`), a tuple (`{MyAction, %{param: value}}`), or a list of either. Instructions are the input format for Plans and are produced by `Jido.Plan` when building execution DAGs.

**Use "Instruction"** when referring to a `Jido.Instruction` struct or the concept of a parameterized, ready-to-execute Action. **Avoid** using "command" as a synonym — `cmd/2` is the function that *processes* Instructions, not the Instruction itself.

**Related:** [Action](#action), [Plan](#plan), [Agent](#agent)

---

### Plan

A Plan defines a DAG (Directed Acyclic Graph) of Instructions with explicit dependency edges. Plans are built using `Jido.Plan.new/0` and a builder API (`Plan.add/3`, `Plan.add/4`) that lets you declare sequential and parallel steps with `depends_on:` constraints. Plans can also be constructed from keyword lists for concise inline definitions. Once built, a Plan can be normalized into a directed graph for execution analysis, validation, and topological ordering. Plans are the mechanism for composing multi-step workflows where some steps depend on others and some can run in parallel.

**Use "Plan"** when referring to a `Jido.Plan` struct or the DAG-based composition of Instructions. **Avoid** "pipeline" or "chain" — a Plan is a graph, not a linear sequence.

**Related:** [Instruction](#instruction), [Action](#action)

---

### Schema

Schema refers to the validated data contracts used throughout Jido, built on the Zoi library. Agents declare state schemas that define the shape and types of their internal state; Actions declare parameter schemas and output schemas that validate inputs and results; Plugins declare both state schemas (scoped under their `state_key`) and configuration schemas. Schemas are enforced at runtime — `Agent.new/1` validates initial state, `cmd/2` validates Action parameters, and Plugin mounting validates configuration. Schema violations raise descriptive errors at the point of entry, not deep inside execution.

**Use "schema"** (lowercase) as a general concept. Refer to specific schemas as "state schema", "parameter schema", "output schema", or "configuration schema" for precision. **Avoid** "type", "spec", or "contract" as synonyms when discussing Zoi-based validation.

**Related:** [Agent](#agent), [Action](#action), [Plugin](#plugin)

---

### Supervision

Supervision in Jido refers to OTP supervision trees that manage AgentServer processes and related infrastructure. `Jido.AgentSupervisor` is a DynamicSupervisor that starts and monitors individual AgentServer processes. When an AgentServer crashes, the supervisor can restart it according to its restart strategy. AgentServer also supports a logical parent-child hierarchy among Agents (via `SpawnAgent` Directives and parent tracking), with configurable behavior on parent death (`:stop`, `:continue`, or `:emit_orphan`). This is distinct from OTP supervision — it is an application-level hierarchy for coordinating Agent lifecycles.

**Use "supervision"** (lowercase) when discussing OTP supervision trees and fault recovery. Use "parent-child hierarchy" when discussing the logical Agent relationship managed by AgentServer. **Avoid** conflating OTP supervision with Agent hierarchy — they are related but distinct mechanisms.

**Related:** [AgentServer](#agentserver), [Directive](#directive)

---

### Orchestration

Orchestration is not a specific Jido type or module — it is the general concept of coordinating multiple Agents, Actions, and Signals to accomplish a goal. In Jido, orchestration emerges from the composition of several primitives: Strategies control how Actions execute within a single Agent; Directives describe inter-process effects like spawning child Agents or emitting Signals; Signal routing in AgentServer maps incoming messages to Actions; and Plans define multi-step execution DAGs. The positioning phrase for Jido's approach is "engineered coordination" — orchestration behavior is explicit, testable, and traceable rather than implicit in prompt chains.

**Use "orchestration"** (lowercase) as a general concept. **Avoid** implying there is an `Orchestrator` module or a single orchestration API — coordination in Jido is distributed across Strategies, Directives, Signals, and Plans.

**Related:** [Strategy](#strategy), [Directive](#directive), [Signal](#signal), [Plan](#plan)

---

### Runtime

Runtime refers to the operational layer of Jido that executes effects, manages processes, and handles the lifecycle of Agents in production. The core runtime component is AgentServer, supported by the supervision tree (`Jido.AgentSupervisor`), the registry (`Jido.Registry`), the scheduler (`Jido.Scheduler`), and observability (`Jido.Observe`). Jido draws a clear architectural line between pure logic (Agents, Actions, Strategies — which are functional and testable in isolation) and the runtime (which introduces processes, side effects, and fault tolerance). The runtime is where Directives are executed, Signals are routed, and supervision provides recovery.

**Use "runtime"** (lowercase) when referring to the operational layer as a whole. Use "AgentServer" when referring to the specific GenServer. The positioning phrase is "runtime for reliable, multi-agent systems." **Avoid** "framework" as a synonym for the runtime layer specifically.

**Related:** [AgentServer](#agentserver), [Supervision](#supervision), [Directive](#directive)

---

### Workflow

Workflow is a general-purpose term for a sequence or graph of work that Agents perform. It is not a Jido-specific type or module. In Jido, workflows are expressed through Plans (DAGs of Instructions), Strategy execution patterns (behavior trees, FSMs), or multi-Agent coordination via Signals and Directives. Use "workflow" when describing what a system accomplishes end-to-end, and use the specific Jido primitives (Plan, Strategy, Signal routing) when describing how it is implemented.

**Use "workflow"** (lowercase) as a general concept. **Avoid** capitalizing it or implying there is a `Workflow` module. Be specific: "a Plan that defines the data-processing workflow" rather than just "a workflow."

**Related:** [Plan](#plan), [Strategy](#strategy), [Orchestration](#orchestration)

---

### Discovery

Discovery (`Jido.Discovery`) is a fast, persistent catalog of all Jido components in an application — Actions, Sensors, Agents, Plugins, and Demos. It uses `:persistent_term` for optimal read performance and is built asynchronously during application startup. Discovery enables runtime introspection: listing available Actions by category or tag, finding components by slug, and powering UI surfaces like dashboards and tool selectors.

**Use "Discovery"** (capitalized) when referring to the `Jido.Discovery` module and its catalog. Use "discovery" (lowercase) when discussing the general concept of finding components at runtime.

**Related:** [Action](#action), [Sensor](#sensor), [Plugin](#plugin)

---

### Scheduler

The Scheduler (`Jido.Scheduler`) provides per-instance cron scheduling using SchedEx. It wraps cron expressions to schedule recurring jobs scoped to individual Agents — each job is supervised as part of the Agent's process tree rather than being a global scheduler. The `Directive.Cron` struct is the typical entry point: Strategies or Actions emit cron Directives, and the runtime calls `Jido.Scheduler.run_every/5` to start the recurring job. Standard 5-field and extended 7-field cron expressions are supported.

**Use "Scheduler"** (capitalized) when referring to `Jido.Scheduler`. **Avoid** "cron" as a standalone synonym — "Scheduler" is the Jido abstraction; cron expressions are the scheduling format it accepts.

**Related:** [Directive](#directive), [AgentServer](#agentserver), [Runtime](#runtime)

---

## Terms not used in Jido

The following terms were considered but do **not** correspond to Jido modules or concepts. Avoid using them in Jido documentation:

- **Runner** — There is no `Runner` module in Jido. Use "AgentServer" for the runtime process that executes Agent logic, or "Strategy" for the execution model within `cmd/2`.
- **Skill** — There is no `Skill` concept in Jido. Use "Plugin" for reusable capability packs or "Action" for individual units of functionality.
- **Operability** — Not a Jido-specific term. Use "production operations", "observability", or reference specific modules like `Jido.Observe` and `Jido.Telemetry`.

---

## Quick reference table

| Term | Module | Capitalized? | One-line definition |
|---|---|---|---|
| Agent | `Jido.Agent` | Yes | Immutable state struct updated via `cmd/2` |
| Action | `Jido.Action` | Yes | Validated, composable unit of functionality |
| Signal | `Jido.Signal` | Yes | CloudEvents-compliant typed message envelope |
| Directive | `Jido.Agent.Directive` | Yes | Pure description of a runtime side effect |
| Strategy | `Jido.Agent.Strategy` | Yes | Pluggable execution model for `cmd/2` |
| AgentServer | `Jido.AgentServer` | Yes | GenServer runtime that executes Directives |
| Plugin | `Jido.Plugin` | Yes | Composable capability module for Agents |
| Sensor | `Jido.Sensor` | Yes | Behaviour that transforms events into Signals |
| Instruction | `Jido.Instruction` | Yes | Action + params + context, ready to execute |
| Plan | `Jido.Plan` | Yes | DAG of Instructions with dependency edges |
| Schema | (Zoi) | No | Validated data contract for state/params/config |
| Supervision | (OTP) | No | OTP process monitoring and restart |
| Orchestration | (concept) | No | Coordinating Agents/Actions/Signals |
| Runtime | (layer) | No | Operational layer: AgentServer + supervision |
| Workflow | (concept) | No | End-to-end sequence or graph of work |
| Discovery | `Jido.Discovery` | Yes | Persistent catalog of components |
| Scheduler | `Jido.Scheduler` | Yes | Per-instance cron scheduling |

### Validation Criteria

- Every definition references the actual Elixir module or explicitly states there is no module
- Capitalization rules align with `marketing/style-voice.md` conventions
- Cross-links connect related terms bidirectionally
- "Avoid" guidance prevents common terminology drift
- Terms not present in the codebase are explicitly called out to prevent phantom concepts
