%{
  title: "Directives and scheduling",
  description: "Isolate side effects from action logic and control execution timing with directives.",
  category: :docs,
  order: 22,
  tags: [:docs, :learn, :directives, :scheduling],
  draft: false
}
---
Agents never perform side effects directly. Actions return directives - pure data structs that describe what should happen - and the runtime executes them later. This separation keeps your logic testable and your failures contained.

## The core invariant

`cmd/2` returns `{agent, directives}`. The agent struct already contains all state updates. Directives are outbound instructions for the runtime, not state mutators.

```elixir
defmodule Fulfillment.ShipOrder do
  use Jido.Action,
    name: "fulfillment.ship_order",
    schema: [
      order_id: [type: :string, required: true],
      carrier: [type: :string, required: true]
    ]

  def run(params, _context) do
    signal = Jido.Signal.new!(
      "order.shipped",
      %{order_id: params.order_id, carrier: params.carrier},
      source: "/fulfillment"
    )

    {:ok, %{status: :shipped}, %Jido.Agent.Directive.Emit{signal: signal}}
  end
end
```

The action returns a state diff (`%{status: :shipped}`) and an `Emit` directive. The runtime applies the state change first, then executes the directive separately.

## Built-in directive types

| Directive | Purpose |
|-----------|---------|
| `Emit` | Dispatch a signal to configured targets |
| `Schedule` | Send a delayed message after an interval |
| `SpawnAgent` | Start a child agent with hierarchy tracking |
| `Spawn` | Start a generic BEAM process (fire-and-forget) |
| `StopChild` | Stop a tracked child agent by tag |
| `RunInstruction` | Execute another `cmd/2` cycle at runtime |
| `Stop` | Terminate the agent process |
| `Cron` / `CronCancel` | Manage recurring scheduled execution |
| `Error` | Signal an error from command processing |

## Emitting signals

`Emit` is the most common directive. You construct a signal and return it from your action.

```elixir
def run(params, _context) do
  signal = Jido.Signal.new!(
    "order.confirmed",
    %{order_id: params.order_id},
    source: "/orders"
  )

  {:ok, %{status: :confirmed}, %Jido.Agent.Directive.Emit{signal: signal}}
end
```

By default the runtime dispatches to the agent's configured `default_dispatch`. You can override the target per directive.

```elixir
# Dispatch to PubSub
%Emit{signal: signal, dispatch: {:pubsub, topic: "events"}}

# Dispatch directly to a pid
%Emit{signal: signal, dispatch: {:pid, target: some_pid}}

# Multiple targets at once
%Emit{signal: signal, dispatch: [
  {:pubsub, topic: "events"},
  {:logger, level: :info}
]}
```

## Scheduling work

The `Schedule` directive sends a message back to the agent after a delay.

```elixir
%Jido.Agent.Directive.Schedule{delay_ms: 5000, message: :check_timeout}
```

Use scheduling for timeouts, polling intervals, and delayed follow-ups. The runtime calls `Process.send_after/3` under the hood, so the message arrives as a signal that routes through your normal signal table.

```elixir
def run(params, _context) do
  {:ok, %{status: :waiting},
    %Jido.Agent.Directive.Schedule{
      delay_ms: params.timeout_ms,
      message: {:payment_timeout, params.order_id}
    }}
end
```

For recurring work, use `Cron` with a cron expression instead.

```elixir
%Jido.Agent.Directive.Cron{
  cron: "*/5 * * * *",
  message: :health_check,
  job_id: :health
}
```

Cancel a recurring job with `CronCancel`.

```elixir
%Jido.Agent.Directive.CronCancel{job_id: :health}
```

## Spawning child agents

`SpawnAgent` creates a child agent with full parent-child hierarchy tracking.

```elixir
%Jido.Agent.Directive.SpawnAgent{
  agent: MyApp.WorkerAgent,
  tag: :worker_1
}
```

The runtime monitors the child process and tracks it in the parent's children map by tag. When a child exits, the parent receives a `jido.agent.child.exit` signal. You can pass metadata and options to the child at spawn time.

```elixir
%Jido.Agent.Directive.SpawnAgent{
  agent: MyApp.WorkerAgent,
  tag: :processor,
  opts: %{initial_state: %{batch_size: 100}},
  meta: %{assigned_topic: "events.user"}
}
```

Use `StopChild` to gracefully shut down a child by tag.

```elixir
%Jido.Agent.Directive.StopChild{tag: :worker_1, reason: :normal}
```

## Multiple directives

A single action can return a list of directives to express compound effects.

```elixir
def run(params, %{state: state}) do
  confirm = Jido.Signal.new!(
    "order.confirmed",
    %{order_id: params.order_id},
    source: "/orders"
  )

  directives = [
    %Jido.Agent.Directive.Emit{signal: confirm},
    %Jido.Agent.Directive.Schedule{
      delay_ms: 30_000,
      message: {:fulfillment_timeout, params.order_id}
    },
    %Jido.Agent.Directive.SpawnAgent{
      agent: MyApp.FulfillmentWorker,
      tag: {:fulfillment, params.order_id}
    }
  ]

  {:ok, %{status: :confirmed}, directives}
end
```

The runtime processes each directive in order.

## How the runtime executes

`AgentServer` enqueues all directives returned from `cmd/2` into an internal queue, then drains them one at a time through the `DirectiveExec` protocol. Each directive type implements `DirectiveExec.exec/3` to perform its specific effect.

The drain loop processes directives sequentially within a single pass. Between drain cycles the GenServer remains free to handle other messages. This keeps side effects ordered without blocking the process indefinitely.

## Directive helpers

The `Jido.Agent.Directive` module provides convenience functions that build directive structs with less boilerplate.

```elixir
alias Jido.Agent.Directive

Directive.emit(signal)
Directive.emit(signal, {:pubsub, topic: "events"})

Directive.schedule(5000, :timeout)

Directive.spawn_agent(MyApp.WorkerAgent, :worker_1)
Directive.spawn_agent(MyApp.WorkerAgent, :processor,
  opts: %{initial_state: %{batch_size: 100}}
)

Directive.stop_child(:worker_1)
Directive.stop()
Directive.cron("*/5 * * * *", :health_check, job_id: :health)
Directive.cron_cancel(:health)
```

For parent-child communication, use `emit_to_parent/3` and `emit_to_pid/3`.

```elixir
Directive.emit_to_pid(signal, worker_pid)
Directive.emit_to_parent(context.agent, reply_signal)
```

## Testing with directives

Call `cmd/2` directly and pattern match on the returned directives. No runtime needed.

```elixir
test "ship order emits shipped signal" do
  agent = FulfillmentAgent.new()

  {agent, directives} = FulfillmentAgent.cmd(
    agent,
    {Fulfillment.ShipOrder, %{order_id: "ord-1", carrier: "ups"}}
  )

  assert agent.state.status == :shipped
  assert [%Jido.Agent.Directive.Emit{signal: signal}] = directives
  assert signal.type == "order.shipped"
  assert signal.data.order_id == "ord-1"
end
```

You can also assert on multiple directives with list pattern matching. Because directives are plain structs, your tests stay fast and deterministic with no processes or supervision trees required.

## Next steps

- [Signals and routing](/docs/learn/signals-routing) - event-driven dispatch and routing tables
- [Directives concept](/docs/concepts/directives) - authoritative reference for the directive system
- [Agent runtime concept](/docs/concepts/agent-runtime) - how AgentServer drains directives
