# Learn tutorials - content briefs

Detailed briefs for the 10 progressive Learn tutorials. Each brief contains enough detail for a writer to produce the full tutorial following `specs/docs-style-guide.md`, `specs/style-voice.md`, and `specs/docs-manifesto.md`.

## Status

| # | Tutorial | Status | File |
|---|----------|--------|------|
| 1 | Build your first workflow | **published** | `learn/first-workflow.livemd` |
| 2 | Plugins and composable agents | **write** | — |
| 3 | State machines with FSM | **write** | — |
| 4 | Parent-child agent hierarchies | **write** | — |
| 5 | Sensors and real-time events | **write** | — |
| 6 | AI agent with tools | **write** | — |
| 7 | Reasoning strategies compared | **write** | — |
| 8 | Task planning and execution | **write** | — |
| 9 | Memory and retrieval-augmented agents | **write** | — |
| 10 | Multi-agent orchestration | **write** | — |

Existing `learn/ai-chat-agent.livemd` will be repositioned or folded into tutorial #6 during writing.

---

## 1. Build your first workflow

**Status:** Published. No changes needed.

**File:** `priv/pages/docs/learn/first-workflow.livemd`

This sets the quality bar for all subsequent tutorials: Livebook-runnable, concrete outcome, progressive code blocks, clear state flow.

---

## 2. Plugins and composable agents

**Frontmatter:**

```elixir
%{
  title: "Plugins and composable agents",
  description: "Build a reusable plugin that adds capabilities to any Jido agent.",
  category: :docs,
  order: 14,
  tags: [:docs, :learn, :plugins, :livebook],
  draft: true,
  prerequisites: ["/docs/learn/first-workflow"]
}
```

**What you build:** A `NotesPlugin` that adds note-taking to any agent. You wire it to two different agents with different configurations and test it through both `cmd/2` and signal routing.

**Key concepts taught:**

- `use Jido.Plugin` with `name`, `state_key`, `actions`, `schema`, `signal_patterns`
- `mount/2` callback for custom initialization from config
- `signal_routes/1` callback for mapping signal types to plugin actions
- Zoi schema for plugin state validation
- Attaching plugins to agents: `plugins: [MyPlugin]` and `plugins: [{MyPlugin, %{config}}]`
- Plugin state access via `agent.state.state_key`
- Plugin signal routing through `AgentServer`

**Codebase references:**

- `jido/test/examples/plugins/plugin_basics_test.exs` — Complete working pattern: NotesPlugin with mount, signal_routes, Zoi schema. AddNoteAction, ClearNotesAction. NotesAgent and ConfiguredNotesAgent showing default and configured plugin usage. Tests for initialization, signal routing, and pure cmd/2.
- `jido/test/examples/plugins/plugin_middleware_test.exs` — Middleware patterns for advanced composition.

**Outline:**

### Why plugins
Agents solve domain problems. Plugins add cross-cutting capabilities - notes, logging, metrics, caching - without cluttering your agent module. A plugin bundles state, actions, and signal routes into one reusable unit. (3-4 sentences, then show the end result first per manifesto rule #6.)

### Define the actions
Two actions: `AddNoteAction` (takes `text`, prepends to notes list with timestamp) and `ClearNotesAction` (resets entries to empty list). Show complete modules with `use Jido.Action`, schemas, and `run/2` implementations. Emphasize that actions read plugin state from `context.state` via the state_key path.

### Build the plugin
`use Jido.Plugin` with all options: `name`, `state_key: :notes`, `actions`, `description`, `schema` (Zoi.object with entries list), `signal_patterns`. Implement `mount/2` to read config (label). Implement `signal_routes/1` to map `"notes.add"` and `"notes.clear"` to actions.

### Wire it to an agent
Define `NotesAgent` with `plugins: [NotesPlugin]`. Show `agent = NotesAgent.new()` and confirm `agent.state.notes.entries == []` and `agent.state.notes.label == "default"`.

### Plugin configuration
Define `ConfiguredNotesAgent` with `plugins: [{NotesPlugin, %{label: "work"}}]`. Show config flows through `mount/2`.

### Use the plugin
Two paths: pure `cmd/2` (call AddNoteAction directly) and signal routing (send `"notes.add"` signal through `AgentServer.call/2`). Show both. Demonstrate multiple signals accumulating state, then clearing.

### Next steps
- [State machines with FSM](/docs/learn/state-machines-with-fsm) - add workflow state management
- [Plugins concept](/docs/concepts/plugins) - full plugin API reference
- [Sensors](/docs/concepts/sensors) - plugins that bridge external events

---

## 3. State machines with FSM

**Frontmatter:**

```elixir
%{
  title: "State machines with FSM",
  description: "Model stateful workflows with defined transitions using the FSM strategy.",
  category: :docs,
  order: 15,
  tags: [:docs, :learn, :fsm, :strategy, :livebook],
  draft: true,
  prerequisites: ["/docs/learn/plugins-and-composable-agents"]
}
```

**What you build:** An order fulfillment agent that transitions through `idle → processing → idle` (default) and a custom version with `ready → processing → done | error` transitions. You inspect state machine snapshots after each operation.

**Key concepts taught:**

- `strategy: Jido.Agent.Strategy.FSM` on an agent
- Default FSM behavior: idle → processing → idle with auto-transition
- Custom transitions map: `%{"ready" => ["processing"], "processing" => ["ready", "done", "error"]}`
- Strategy tuple syntax: `{Jido.Agent.Strategy.FSM, initial_state: "ready", transitions: %{...}}`
- `auto_transition: false` for manual state management
- `FSM.snapshot/2` for inspecting status, fsm_state, processed_count, last_result
- Running action lists within FSM and processed_count tracking

**Codebase references:**

- `jido/test/examples/fsm/fsm_agent_test.exs` — SimpleFSMAgent (default transitions), CustomTransitionAgent (custom transition map with initial_state "ready"), NoAutoTransitionAgent, IncrementCounter, ProcessWorkAction, CompleteTaskAction. Tests showing snapshot inspection, multiple actions, auto_transition behavior.

**Outline:**

### When state machines fit
Order processing, approval workflows, game states - anywhere transitions must follow defined paths. Show the before (ad-hoc status tracking in state) vs. after (FSM-enforced transitions).

### Default FSM agent
Define an agent with `strategy: Jido.Agent.Strategy.FSM` and simple schema. Create it, run a command, show FSM.snapshot/2 output: status, fsm_state, processed_count. Demonstrate the auto-transition from idle → processing → idle.

### Custom transitions
Define `OrderFulfillmentAgent` with `{Jido.Agent.Strategy.FSM, initial_state: "pending", transitions: %{"pending" => ["validated"], "validated" => ["processing", "cancelled"], ...}}`. Show how invalid transitions are rejected.

### Controlling auto-transition
`auto_transition: false` keeps the agent in "processing" after a command. Show with snapshot. Explain when you'd want this (multi-step processing where the agent should stay in a working state).

### Inspecting FSM state
Deep dive on `FSM.snapshot/2`: `.status` (atom), `.done?` (boolean), `.details.fsm_state` (string), `.details.processed_count` (integer), `.result` (last action output). Show snapshot after each transition.

### Multiple actions in FSM
Pass a list of actions to `cmd/2`. Show that processed_count increments for each. Demonstrate mixed action types accumulating state.

### Next steps
- [Parent-child agent hierarchies](/docs/learn/parent-child-agent-hierarchies) - compose agents across process boundaries
- [Strategy concept](/docs/concepts/strategy) - all available execution strategies
- [Agent runtime concept](/docs/concepts/agent-runtime) - how AgentServer runs strategies

---

## 4. Parent-child agent hierarchies

**Frontmatter:**

```elixir
%{
  title: "Parent-child agent hierarchies",
  description: "Spawn child agents, route signals between layers, and aggregate results.",
  category: :docs,
  order: 16,
  tags: [:docs, :learn, :hierarchies, :runtime, :livebook],
  draft: true,
  prerequisites: ["/docs/learn/state-machines-with-fsm"]
}
```

**What you build:** A 3-layer job processing system. An Orchestrator spawns Coordinator agents. Each Coordinator spawns Worker agents for individual tasks. Workers execute and emit results upward. Coordinators aggregate worker results and report to the Orchestrator.

**Key concepts taught:**

- `Jido.Agent.Directive.SpawnAgent` for spawning child agents with tags and metadata
- `Directive.emit_to_parent/2` for sending results upward
- `Directive.emit_to_pid/2` for targeted signal delivery
- `Directive.stop_child/1` for stopping children
- `jido.agent.child.started` built-in signal for child lifecycle
- Children tracking in `agent.state.children`
- `Jido.start_agent/3` and `AgentServer.call/2` for runtime interaction
- Signal flow patterns: downward work assignment, upward result bubbling

**Codebase references:**

- `jido/test/examples/runtime/hierarchical_agents_test.exs` — Full 3-layer hierarchy (650 lines). OrchestratorAgent (SubmitJobAction, HandleJobResultAction), CoordinatorAgent (HandleJobAssignAction, CoordinatorChildStartedAction, HandleTaskResultAction), WorkerAgent (ExecuteTaskAction). Signal types: submit_job, job.assign, task.execute, task.result, job.result. Shows pending/completed tracking, result aggregation, trace propagation.
- `jido/test/examples/runtime/parent_child_test.exs` — Simpler 2-layer parent-child for reference.
- `jido/test/examples/runtime/spawn_agent_test.exs` — SpawnAgent directive basics.

**Outline:**

### The hierarchy pattern
Some work decomposes naturally: a job becomes tasks, tasks become operations. Show the architecture diagram (Orchestrator → Coordinator → Worker) with signal flow in both directions. Explain when to use this vs. action composition.

### Define the Worker
WorkerAgent with ExecuteTaskAction. The action processes a task (compute/validate/transform), builds a result signal, and uses `Directive.emit_to_parent` to send it up. Show the complete action module.

### Define the Coordinator
CoordinatorAgent with HandleJobAssignAction (receives job, spawns workers via SpawnAgent directives), CoordinatorChildStartedAction (reacts to child started, sends task.execute signal to worker pid), HandleTaskResultAction (collects results, when all complete emits job.result to parent).

### Define the Orchestrator
OrchestratorAgent with SubmitJobAction (receives job submission, spawns coordinator), HandleJobResultAction (aggregates final results). Show pending_jobs and completed_jobs state tracking.

### Wire the signal routes
Show each agent's signal_routes mapping: orchestrator handles submit_job + job.result + child.started, coordinator handles job.assign + task.result + child.started, worker handles task.execute.

### Run the hierarchy
Start the orchestrator with `Jido.start_agent`. Send a submit_job signal with multiple tasks. Show results flowing through all three layers. Inspect final state.

### Inspect state across layers
Use `AgentServer.state/1` to check children maps at each level. Show how the orchestrator's children map contains coordinators, and each coordinator's children map contains workers.

### Next steps
- [Sensors and real-time events](/docs/learn/sensors-and-real-time-events) - connect external signals to agent hierarchies
- [Directives concept](/docs/concepts/directives) - full directive API reference
- [Agent runtime concept](/docs/concepts/agent-runtime) - supervision and process lifecycle

---

## 5. Sensors and real-time events

**Frontmatter:**

```elixir
%{
  title: "Sensors and real-time events",
  description: "Connect external data sources to agents via sensors and dynamic signal routing.",
  category: :docs,
  order: 17,
  tags: [:docs, :learn, :sensors, :signals, :livebook],
  draft: true,
  prerequisites: ["/docs/learn/parent-child-agent-hierarchies"]
}
```

**What you build:** An agent that receives data from a polling sensor (simulated external API) and processes webhook payloads. You add context-aware routing that changes behavior based on agent mode (normal vs. maintenance).

**Key concepts taught:**

- `Jido.Sensor` for bridging external events into agent signal flow
- Sensor configuration: polling intervals, signal types, data extraction
- Webhook signal injection via `AgentServer.call/2`
- `signal_routes/1` with context parameter for dynamic routing
- Mode-based routing: same signal type, different action based on agent state
- Combining sensors and manual signal injection

**Codebase references:**

- `jido/test/examples/observability/sensor_demo_test.exs` — HandleQuoteAction, HandleWebhookAction, QuoteSensor with polling, SensorDemoAgent with signal_routes, webhook signal injection, state accumulation from sensor signals.
- `jido/test/examples/signals/context_aware_routing_test.exs` — ProcessAction, MaintenanceAction, mode-based routing with signal_routes/1 context parameter, ModeAwareAgent, ContextAwarePlugin.

**Outline:**

### Why sensors
Agents are reactive by design - they respond to signals. Sensors bridge the gap between external systems (APIs, webhooks, message queues, file watchers) and the agent signal model. Show the flow: external source → sensor → signal → agent → action.

### Define the actions
HandleQuoteAction (processes incoming data, appends to a quotes list with metadata), HandleWebhookAction (processes webhook payloads with different handling). Both read and update `context.state`.

### Build a sensor
Define a sensor that polls an external source and emits signals at a configured interval. Show sensor configuration: polling frequency, signal type, target agent. Explain how the sensor emits signals that the agent's router picks up.

### Wire the agent
SensorDemoAgent with signal_routes mapping sensor signal types to handler actions. Show the agent receiving sensor signals and accumulating state.

### Context-aware routing
Define a ModeAwareAgent where `signal_routes/1` receives context and returns different routes based on agent mode. Normal mode routes to ProcessAction, maintenance mode routes to MaintenanceAction. Show how the same incoming signal produces different behavior.

### Webhook injection
Send signals directly to agents via `AgentServer.call/2` to simulate webhooks. Show how external HTTP payloads become signals that flow through the same routing infrastructure.

### Testing sensor-driven agents
Test patterns: start agent, trigger sensor/webhook signals, assert on accumulated state. No external dependencies needed.

### Next steps
- [AI agent with tools](/docs/learn/ai-agent-with-tools) - bridge to AI-powered agents
- [Sensors concept](/docs/concepts/sensors) - full sensor API reference
- [Signals concept](/docs/concepts/signals) - signal types and dispatch adapters

---

## 6. AI agent with tools

**Frontmatter:**

```elixir
%{
  title: "AI agent with tools",
  description: "Build a ReAct agent that reasons iteratively and calls tools to answer questions.",
  category: :docs,
  order: 30,
  tags: [:docs, :learn, :ai, :tools, :react, :livebook],
  draft: true,
  prerequisites: ["/docs/getting-started/first-llm-agent"]
}
```

**What you build:** A weather assistant agent that uses real tools (geocoding, forecast lookup, current conditions) through the ReAct reasoning loop. The agent interprets user questions, calls the right tools, and synthesizes practical advice.

**Key concepts taught:**

- `use Jido.AI.Agent` with `tools:`, `system_prompt:`, `model:`, `max_iterations:`
- Tool definitions from Action modules (name, description, schema → JSON Schema)
- The ReAct loop: prompt → LLM reasons → tool_call → execute action → result → LLM reasons again
- `ask/2` + `await/2` for async requests, `ask_sync/3` for synchronous convenience
- `strategy_snapshot/1` for checking reasoning progress
- `request_policy:` for concurrent request handling
- Tool configuration: `tool_timeout_ms`, `tool_max_retries`, `tool_retry_backoff_ms`
- Lifecycle hooks: `on_before_cmd/2` for context enrichment, `on_after_cmd/3` for state sync
- Observability: `emit_telemetry?`, `emit_lifecycle_signals?`, `redact_tool_args?`
- Domain-specific helper methods wrapping `ask_sync`
- Testing with Mimic stubs (no live LLM calls)

**Codebase references:**

- `jido_ai/lib/examples/agents/weather_agent.ex` — Production-quality WeatherAgent with 6 tools, observability config, helper methods (get_forecast, get_conditions, need_umbrella?), detailed system prompt, request_policy: :reject, tool timeout/retry config.
- `jido_ai/test/jido_ai/examples/weather_agent_test.exs` — Testing with Mimic stubs for ReqLLM.Generation.stream_text, runtime adapter verification.
- `jido_ai/lib/examples/tools/weather_by_location.ex` — Example tool action.

**Outline:**

### Beyond simple chat
The first-llm-agent tutorial showed a basic LLM call. Real agents need to take actions: look up data, call APIs, perform calculations. Tools bridge the gap between LLM reasoning and real-world capabilities. Show the end result: ask a weather question, get a tool-informed answer.

### Define the tool actions
Show 2-3 tool action modules with `use Jido.Action`, descriptive names, Zoi schemas with field descriptions (these become the tool descriptions the LLM sees). Demonstrate how the same module works as a programmatic action and an LLM-callable tool.

### Build the AI agent
`use Jido.AI.Agent` with tools list, system_prompt, model, max_iterations. Walk through each configuration option. Explain how system_prompt shapes tool usage behavior.

### The ReAct loop
Diagram and explain: user question → LLM receives prompt + tool definitions → LLM decides to call a tool → Jido executes the action → result goes back to LLM → LLM reasons about the result → either calls another tool or produces final answer. Show max_iterations as a safety bound.

### Helper methods
Wrap `ask_sync` in domain-specific methods: `get_forecast/3`, `get_conditions/3`. Show how these provide a clean API for callers while the agent handles all the LLM reasoning internally.

### Lifecycle hooks
`on_before_cmd/2` to enrich prompts with live context. `on_after_cmd/3` to sync results back to state. Show the weather agent's pattern of enriching prompts with real-time data.

### Observability and configuration
Tool timeout, retry, and backoff configuration. Telemetry emission for monitoring. Signal redaction for security.

### Testing with stubs
Use Mimic to stub `ReqLLM.Generation.stream_text`. Test that the agent starts, processes requests, and returns results without any live LLM calls. Show the testing pattern.

### Next steps
- [Reasoning strategies compared](/docs/learn/reasoning-strategies-compared) - explore CoT, ToT, and Adaptive
- [Tool use concept](/docs/concepts/actions) - Action-to-tool conversion reference
- [Build an AI chat agent](/docs/learn/ai-chat-agent) - multi-turn conversation patterns

---

## 7. Reasoning strategies compared

**Frontmatter:**

```elixir
%{
  title: "Reasoning strategies compared",
  description: "Solve the same problem with Chain-of-Thought, Tree-of-Thoughts, and Adaptive strategies.",
  category: :docs,
  order: 31,
  tags: [:docs, :learn, :ai, :strategies, :cot, :tot, :adaptive, :livebook],
  draft: true,
  prerequisites: ["/docs/learn/ai-agent-with-tools"]
}
```

**What you build:** Three weather advisory agents that solve the same problem using different reasoning strategies: CoT (step-by-step), ToT (branching exploration), and Adaptive (automatic selection). You compare their outputs and understand when each fits.

**Key concepts taught:**

- `use Jido.AI.CoTAgent` — step-by-step transparent reasoning
- `use Jido.AI.ToTAgent` — branching exploration of multiple solution paths
- `use Jido.AI.AdaptiveAgent` — automatic strategy selection based on problem analysis
- Strategy-specific helpers: `think_sync`, `explore_sync`, `coach_sync`
- Strategy-specific config: `default_strategy`, `available_strategies`, `complexity_thresholds`
- `cli_adapter/0` and `mix jido_ai` for running agents from command line
- All 8 strategies overview: ReAct, CoT, CoD, AoT, ToT, GoT, TRM, Adaptive

**Codebase references:**

- `jido_ai/lib/examples/weather/cot_agent.ex` — CoTAgent with weather_decision_sync, on_before_cmd enrichment via LiveContext.
- `jido_ai/lib/examples/weather/tot_agent.ex` — ToTAgent with weekend_options_sync, format_top_options.
- `jido_ai/lib/examples/weather/adaptive_agent.ex` — AdaptiveAgent with coach_sync.
- `jido_ai/lib/examples/weather/overview.ex` — All 8 strategy agents indexed, CLI examples.
- `jido_ai/test/jido_ai/examples/weather_strategy_suite_test.exs` — Tests: all strategy modules, CLI adapter resolution, helper entrypoints.
- `jido_ai/lib/jido_ai/agents/strategies/adaptive_agent.ex` — AdaptiveAgent macro docs: default_strategy, available_strategies, complexity_thresholds, generated functions.

**Outline:**

### One problem, many strategies
Introduce the problem: "Should I bike or drive to work given the weather?" Different strategies approach this differently. Show a table of all 8 strategies with one-sentence descriptions and when each fits.

### Chain-of-Thought
Define a CoT weather advisor with `use Jido.AI.CoTAgent`. Show system_prompt designed for explicit step-by-step reasoning. Implement `weather_decision_sync` helper. Run it and show the structured output: known facts → assumptions → recommendation.

### Tree-of-Thoughts
Define a ToT weather advisor with `use Jido.AI.ToTAgent`. Show how it explores multiple options (bike vs. drive vs. transit) in parallel branches and evaluates each. Implement `weekend_options_sync` and `format_top_options`. Show branching output.

### Adaptive
Define an Adaptive advisor with `use Jido.AI.AdaptiveAgent`. Configure `default_strategy`, `available_strategies`, `complexity_thresholds`. Show how it analyzes the problem and selects the best strategy automatically. Implement `coach_sync`.

### Choosing the right strategy
Decision matrix table:

| Strategy | Best for | Tradeoff |
|----------|----------|----------|
| ReAct | Tool-calling, iterative data gathering | More LLM calls |
| CoT | Transparent reasoning, explainable decisions | Linear, single path |
| CoD | Quick condensed answers | Less detailed |
| ToT | Multiple alternatives, exploration | Higher token cost |
| GoT | Multi-perspective analysis | Complex setup |
| TRM | Stress-testing plans, critique | Slower |
| AoT | Algorithmic/structured problems | Narrow scope |
| Adaptive | Unknown problem complexity | Extra analysis step |

### Running from the CLI
Show `mix jido_ai --agent MyApp.CoTWeatherAgent "question"` for each strategy. Explain cli_adapter/0.

### Next steps
- [Task planning and execution](/docs/learn/task-planning-and-execution) - agents that decompose and execute goals
- [Strategy concept](/docs/concepts/strategy) - full strategy API reference
- [AI chat agent](/docs/learn/ai-chat-agent) - multi-turn conversation patterns

---

## 8. Task planning and execution

**Frontmatter:**

```elixir
%{
  title: "Task planning and execution",
  description: "Build an agent that decomposes goals into tasks and executes them iteratively.",
  category: :docs,
  order: 32,
  tags: [:docs, :learn, :ai, :planning, :tasks, :memory, :livebook],
  draft: true,
  prerequisites: ["/docs/learn/ai-agent-with-tools"]
}
```

**What you build:** A task planning agent that receives a goal, decomposes it into actionable tasks stored in Memory spaces, and works through each task iteratively using the ReAct loop. Tasks persist across reasoning iterations.

**Key concepts taught:**

- `Jido.Memory.Agent` helpers: `ensure/2`, `space/2`, `update_space/4`
- Memory spaces as persistent structured storage (`:tasks` list space)
- Tool context injection: loading state into `params.tool_context` via `on_before_cmd`
- Task state synchronization: extracting tool results from conversation in `on_after_cmd`
- System prompt engineering for mandatory tool-usage workflows
- Request lifecycle: `Request.ensure_request_id`, `Request.start_request`, `Request.complete_request`
- Custom tool actions: AddTasks, GetState, NextTask, StartTask, CompleteTask, BlockTask
- Multi-iteration ReAct with persistent state between iterations

**Codebase references:**

- `jido_ai/lib/examples/agents/task_list_agent.ex` — Full TaskListAgent (330 lines): 7 custom tools, Memory integration, task extraction from conversation (parse_tool_results, apply_task_action), lifecycle hooks for loading/syncing tasks, system prompt with mandatory workflow, helper methods (plan, execute, status, resume).
- `jido_ai/lib/examples/tools/task_list.ex` — Tool action implementations.
- `jido/test/examples/plugins/memory_plugin_test.exs` — Memory.Agent helper patterns.

**Outline:**

### Beyond one-shot answers
Most real work requires planning: break a goal into steps, execute each step, handle blockers, report progress. Show the end result: give the agent a goal, watch it create a plan, execute tasks, and deliver results.

### Memory spaces for task storage
Introduce `Jido.Memory.Agent` helpers. Show how to ensure a memory space exists, read from it, write to it. Explain list vs. KV spaces. The `:tasks` space stores a list of task maps with id, title, description, priority, status.

### Define the task tools
Walk through 4-5 key tool actions: AddTasks (creates task list from goal decomposition), GetState (shows current tasks), NextTask (returns next pending task), StartTask (marks task in-progress), CompleteTask (records result). Show schemas with descriptions for LLM visibility.

### Build the agent
`use Jido.AI.Agent` with tools, system prompt, max_iterations: 25. The system prompt is critical: it must enforce a mandatory workflow (get_state → add_tasks → next_task → start → complete → repeat). Show the prompt engineering pattern.

### Lifecycle hooks
`on_before_cmd/2`: load tasks from Memory, inject into tool_context so tools have current state. `on_after_cmd/3`: extract tool results from the ReAct conversation, sync task state changes back to Memory. Show the extract_tasks_from_conversation pattern.

### Task state synchronization
Explain the flow: Memory → tool_context → tools → LLM → tool calls → conversation → extract → Memory. Show how parse_tool_results scans conversation for tool outputs and apply_task_action updates the task list.

### Running multi-step goals
Start the agent, call `execute(pid, "Write a README for a new library")`. Show the agent creating 5 tasks, working through each, producing detailed results. Demonstrate `status/1` and `resume/1` for checking progress and continuing interrupted work.

### Next steps
- [Memory and retrieval-augmented agents](/docs/learn/memory-and-retrieval-augmented-agents) - deeper memory patterns and RAG
- [Plugins concept](/docs/concepts/plugins) - Memory and Thread as default plugins
- [AI agent with tools](/docs/learn/ai-agent-with-tools) - revisit tool patterns

---

## 9. Memory and retrieval-augmented agents

**Frontmatter:**

```elixir
%{
  title: "Memory and retrieval-augmented agents",
  description: "Add persistent memory and retrieval-based context injection to AI agents.",
  category: :docs,
  order: 33,
  tags: [:docs, :learn, :ai, :memory, :retrieval, :rag, :livebook],
  draft: true,
  prerequisites: ["/docs/learn/task-planning-and-execution"]
}
```

**What you build:** An agent with three memory layers: Memory plugin for structured data, Thread plugin for conversation history, and Retrieval store for semantic recall. You implement checkpoint/restore for persistence across restarts and build a knowledge-aware agent that injects relevant context into prompts.

**Key concepts taught:**

- Memory plugin: spaces (KV and list), `ensure/2`, `put_in_space/4`, `get_in_space/4`, `append_to_space/3`, `space/2`, `spaces/1`, `delete_space/2`, `update_space/4`
- Thread plugin: `append/3`, `get/1`, `has_thread?/1`, conversation history as structured entries, auto-tracked instruction lifecycle
- `Jido.AI.Retrieval.Store`: `upsert/2`, `recall/3` with top_k and min_score, token-overlap scoring, namespaces
- Checkpoint/restore hooks: `on_checkpoint/2` returning `:keep`, `:drop`, or `{:externalize, key, pointer}`, `on_restore/2` for rehydration
- Thread.Plugin externalization: thread → `%{id, rev}` pointer
- Combining all three in a single agent

**Codebase references:**

- `jido/test/examples/plugins/memory_plugin_test.exs` — Memory.Agent helpers, UpdateWorldAction, space management, KV operations.
- `jido/test/examples/plugins/thread_plugin_test.exs` — Thread.Agent helpers, RecordMessageAction, SummarizeAction, conversation history building, auto-tracked instructions.
- `jido/test/examples/persistence/checkpoint_restore_test.exs` — CachePlugin (:drop), SessionPlugin (:externalize + on_restore), CheckpointableAgent with mixed strategies, Thread.Plugin externalization as `%{id, rev}`.
- `jido_ai/lib/jido_ai/retrieval/store.ex` — ETS-backed store with upsert, recall (token-overlap scoring, top_k, min_score), clear, all, namespace management.
- `jido_ai/test/jido_ai/actions/retrieval/upsert_memory_test.exs` — Upsert action patterns.
- `jido_ai/test/jido_ai/actions/retrieval/recall_memory_test.exs` — Recall action patterns.

**Outline:**

### Why memory matters
Stateless agents forget everything between turns. Show the problem: ask the same agent two questions, it has no context from the first. Then show the solution: an agent that remembers previous interactions and retrieves relevant knowledge.

### Memory plugin
Show Memory.Agent helpers: ensure a memory space, store structured data (user preferences, session context), retrieve it later. Build an agent that tracks user preferences in a `:preferences` KV space and project notes in a `:notes` list space.

### Thread plugin
Show Thread.Agent helpers: append conversation entries, retrieve history, check if thread exists. Build conversation tracking with RecordMessageAction. Show auto-tracked instruction lifecycle entries that the strategy layer adds automatically.

### Retrieval store
Introduce `Jido.AI.Retrieval.Store`: upsert documents with text and metadata into namespaces, recall relevant documents given a query. Show token-overlap scoring, top_k, min_score parameters. Build a knowledge base the agent can search.

### Building a knowledge-aware agent
Combine all three: Memory for structured state, Thread for conversation history, Retrieval for semantic search. In `on_before_cmd/2`, recall relevant documents and inject them into the prompt context. Show the RAG pattern: query → recall → augment prompt → generate.

### Checkpoint and restore
Define plugins with different checkpoint strategies: `:keep` (include in checkpoint), `:drop` (ephemeral cache, exclude), `{:externalize, key, pointer}` (store a reference, rehydrate on restore). Show Thread.Plugin's built-in externalization to `%{id, rev}`. Run `checkpoint/2` and inspect the result.

### Testing memory-augmented agents
Test patterns for each layer: verify memory space contents after actions, verify thread entries accumulate, verify retrieval recall returns relevant results, verify checkpoint/restore round-trips.

### Next steps
- [Multi-agent orchestration](/docs/learn/multi-agent-orchestration) - coordinate memory-aware agents
- [Persistence guide](/docs/guides/persistence-memory-and-vector-search) - production persistence patterns
- [Plugins concept](/docs/concepts/plugins) - default plugin reference

---

## 10. Multi-agent orchestration

**Frontmatter:**

```elixir
%{
  title: "Multi-agent orchestration",
  description: "Coordinate specialized AI sub-agents with the Skills system and Planning plugin.",
  category: :docs,
  order: 34,
  tags: [:docs, :learn, :ai, :multi-agent, :skills, :planning, :livebook],
  draft: true,
  prerequisites: ["/docs/learn/memory-and-retrieval-augmented-agents"]
}
```

**What you build:** A coordinator agent that manages three specialized AI sub-agents (planner, researcher, writer). The coordinator decomposes a complex goal using the Planning plugin, delegates sub-tasks to specialist agents via signals, and aggregates their outputs into a final result.

**Key concepts taught:**

- Skills system: `Jido.AI.Skill.Spec` (name, description, actions, plugins, tags), Skill.Loader, Skill.Registry
- Planning plugin: `Jido.AI.Plugins.Planning` with Plan, Decompose, Prioritize actions
- Chat plugin: `Jido.AI.Plugins.Chat` with LLM actions (Chat, Complete, Embed, GenerateObject) and tool-calling actions (CallWithTools, ExecuteTool, ListTools)
- Reasoning plugins: composing strategy-specific plugins (ChainOfThought, TreeOfThoughts, etc.)
- Combining hierarchical spawning (from tutorial #4) with AI strategies
- Multi-agent signal flow: coordinator sends work signals, specialists return results
- Plugin composition: multiple AI plugins on a single agent

**Codebase references:**

- `jido_ai/lib/examples/scripts/demo/skills_multi_agent_orchestration_demo.exs` — Multi-agent orchestration patterns.
- `jido_ai/test/jido_ai/integration/skills_phase5_test.exs` — Plugin composition tests: Chat, Planning, Reasoning plugins. Action inventories. State independence across plugins.
- `jido_ai/lib/jido_ai/skill/spec.ex` — Skill spec structure: name, description, actions, plugins, tags, body_ref.
- `jido_ai/test/jido_ai/skill_test.exs` — Skill loading and registration.
- `jido_ai/test/jido_ai/integration/strategies_phase4_test.exs` — Strategy execution, signal routing, directive emission, adaptive strategy selection.
- `jido/test/examples/runtime/hierarchical_agents_test.exs` — Hierarchical agent patterns (reuse from tutorial #4).

**Outline:**

### When one agent isn't enough
Complex goals require different capabilities: planning, research, writing, review. Instead of one giant agent, compose specialists that each do one thing well. Show the end result: give the coordinator a complex goal, watch it decompose, delegate, and assemble.

### The Skills system
Introduce `Jido.AI.Skill.Spec`: a declarative description of what an agent can do (actions, plugins, metadata). Show how skills compose into agent capabilities. Walk through Skill.Loader and Skill.Registry for runtime skill discovery.

### Planning plugin
Add `Jido.AI.Plugins.Planning` to an agent. Use the Plan, Decompose, and Prioritize actions to break a complex goal into ordered sub-tasks. Show how the planning output drives orchestration decisions.

### Define specialist agents
Create three specialist AI agents, each with different tools and strategies:
- PlannerAgent (CoT strategy, Planning plugin, structured decomposition)
- ResearcherAgent (ReAct strategy, search/retrieval tools, data gathering)
- WriterAgent (CoD strategy, synthesis focus, output generation)

### Build the coordinator
Combine hierarchical spawning with AI reasoning. The coordinator receives a goal, uses the Planning plugin to decompose it, spawns specialist agents via SpawnAgent directives, and routes sub-tasks as signals.

### Signal flow across AI agents
Show the full cycle: coordinator emits work signals to specialists, specialists process with their own strategies, specialists emit result signals back. The coordinator aggregates results using HandleResultAction.

### End-to-end orchestration
Run a complex multi-agent workflow. Give the coordinator a real goal (e.g., "Research and write a technical comparison of X vs Y"). Watch the planner decompose, the researcher gather data, and the writer produce output.

### Next steps
- [Guides](/docs/guides) - task-focused recipes for production patterns
- [Concepts](/docs/concepts) - deep reference for all Jido primitives
- [Ecosystem](/docs/ecosystem) - explore additional Jido packages
