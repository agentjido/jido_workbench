%{
  title: "Strategy",
  description: "Pluggable execution models that control how agents process actions.",
  category: :docs,
  order: 100,
  draft: false,
  tags: [:docs, :concepts]
}
---
Every agent needs to decide how to run its actions. A Strategy is the pluggable execution model that controls this. It sits between the agent's `cmd/2` call and the actual action execution, letting you swap execution semantics without changing your agent or action code.

Jido ships with `Jido.Agent.Strategy.Direct` as the default. You can replace it with a behavior tree, an LLM chain of thought, or any custom execution pattern by implementing a single callback.

## What strategies solve

Without strategies, execution logic gets baked into the agent definition. Every agent that needs retry logic, staged execution, or multi-step planning would need its own `cmd/2` implementation. This couples the agent's state model to its runtime behavior.

Strategies decouple these concerns. Your agent defines state shape and validation. Your actions define pure transformations. Your strategy decides how those actions run: sequentially, in stages, with LLM-driven planning, or through a behavior tree.

The same agent struct and actions work identically under different strategies. Swap from `Direct` to a custom planner and your tests, state contracts, and action logic stay unchanged.

## The strategy contract

A strategy implements the `Jido.Agent.Strategy` behaviour. The only required callback is `cmd/3`. Three optional callbacks handle initialization, multi-step execution, and state inspection.

```elixir
@callback cmd(agent, instructions, context) :: {agent, directives}
@callback init(agent, context) :: {agent, directives}
@callback tick(agent, context) :: {agent, directives}
@callback snapshot(agent, context) :: Strategy.Snapshot.t()
```

**`cmd/3`** (required) receives the agent, a list of normalized `Instruction` structs, and an execution context. It returns the updated agent and a list of directives. This is where your execution logic lives.

**`init/2`** (optional) is called by `AgentServer` after `new/1` and before the first `cmd/2`. Use it to set up strategy-specific state. Implementations should be idempotent because `init/2` may be called more than once.

**`tick/2`** (optional) is called by `AgentServer` when a strategy has scheduled a tick via the `{:schedule, ms, :strategy_tick}` directive. Use it for multi-step execution that spans multiple turns.

**`snapshot/2`** (optional) returns a `Strategy.Snapshot` struct that exposes strategy state without leaking internal details. The default implementation reads from `Strategy.State` helpers automatically.

Every callback receives a context map containing `:agent_module` and `:strategy_opts`.

## Direct strategy

`Jido.Agent.Strategy.Direct` is the default and handles most use cases. It executes instructions sequentially and immediately in a single pass.

For each instruction, Direct calls `Jido.Exec.run/1`, merges the result into agent state, separates internal state operations from external directives, and moves to the next instruction. If an instruction fails, it emits an error directive and continues.

```elixir
defmodule MyApp.OrderAgent do
  use Jido.Agent,
    name: "order_agent",
    schema: Zoi.object(%{total: Zoi.integer() |> Zoi.default(0)})
end

# Direct strategy is implicit. No configuration needed.
agent = MyApp.OrderAgent.new()
{agent, directives} = MyApp.OrderAgent.cmd(agent, MyApp.AddItem)
```

Start with `Direct` unless you can name the specific runtime behavior you need from a custom strategy.

## Custom strategies

To build a custom strategy, `use Jido.Agent.Strategy` and implement `cmd/3`. The `use` macro provides default implementations of `init/2`, `tick/2`, and `snapshot/2` that you can override as needed.

```elixir
defmodule MyApp.RetryStrategy do
  use Jido.Agent.Strategy

  @impl true
  def cmd(agent, instructions, ctx) do
    max_retries = ctx.strategy_opts[:max_retries] || 3

    Enum.reduce(instructions, {agent, []}, fn instr, {acc, dirs} ->
      {new_agent, new_dirs} = run_with_retry(acc, instr, max_retries)
      {new_agent, dirs ++ new_dirs}
    end)
  end
end
```

Set the strategy at compile time in your agent definition. Pass a module directly or a `{module, opts}` tuple to provide options through `ctx.strategy_opts`.

```elixir
defmodule MyApp.ResilientAgent do
  use Jido.Agent,
    name: "resilient_agent",
    strategy: {MyApp.RetryStrategy, max_retries: 5}
end
```

Strategy state lives inside `agent.state` under the reserved key `:__strategy__`. Use the `Jido.Agent.Strategy.State` helpers to manage it without reaching into agent internals directly.

```elixir
alias Jido.Agent.Strategy.State, as: StratState

agent = StratState.put(agent, %{module: __MODULE__, status: :running})
status = StratState.status(agent)    # => :running
active? = StratState.active?(agent)  # => true
```

## Multi-step execution

Some strategies need to execute across multiple turns. A behavior tree might pause at a waiting node. An LLM planner might need to process a response before deciding the next step.

The `tick/2` callback supports this pattern. After `cmd/3` sets up initial state, the strategy emits a `{:schedule, ms, :strategy_tick}` directive. The `AgentServer` calls `tick/2` when the scheduled time arrives, and the strategy can continue execution or schedule another tick.

Use `snapshot/2` to inspect strategy progress without coupling to internal state. The `Strategy.Snapshot` struct provides a stable interface across all strategy implementations.

```elixir
snap = MyApp.PlannerStrategy.snapshot(agent, ctx)
snap.status   # => :running, :waiting, :success, or :failure
snap.done?    # => true when status is :success or :failure
snap.result   # => the strategy's main output, if any
snap.details  # => strategy-specific metadata
```

This keeps callers decoupled from how a strategy represents its internal progress. Whether you build a behavior tree or an LLM chain, consumers read the same `Snapshot` struct.

## Next steps

- [Agents](/docs/concepts/agents) for the full agent contract and `cmd/2` lifecycle
- [Actions](/docs/concepts/actions) to understand the pure functions that strategies execute
- [Directives](/docs/concepts/directives) for the effect payloads that strategies return
- [Agent runtime](/docs/concepts/agent-runtime) to run strategy-backed agents under OTP supervision
