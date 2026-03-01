%{
  title: "Signals and routing",
  description: "Create typed event envelopes and route them to actions with pattern-matched dispatch.",
  category: :docs,
  order: 23,
  tags: [:docs, :learn, :signals, :routing],
  draft: false
}
---
Signals are the universal message format in Jido. They implement CloudEvents v1.0.2 and connect sensors, agents, and external systems through a typed envelope. Every signal carries a type, source, data payload, and auto-generated UUID v7 ID.

## Creating signals

`Jido.Signal.new/3` takes a type string, an optional data map, and keyword options. The bang variant `new!/3` raises on failure instead of returning an error tuple.

```elixir
# Positional constructor
{:ok, signal} = Jido.Signal.new("user.created", %{user_id: "usr_901"}, source: "/auth")

# Bang version
signal = Jido.Signal.new!("order.placed", %{order_id: "ord_42"}, source: "/orders")
```

`type` and `source` are required. `data` defaults to an empty map. `time` is auto-generated as an ISO 8601 timestamp and `id` is a UUID v7.

## Type naming conventions

Use hierarchical dot notation following `<domain>.<entity>.<action>`. This keeps types scannable and enables wildcard routing.

```
user.profile.updated
order.payment.processed.success
system.metrics.collected
```

Keep segments lowercase and avoid abbreviations. Three segments is the sweet spot for most events.

## Custom signal types

Define reusable signal modules with `use Jido.Signal` to lock the type, set a default source, and validate the data payload against a schema.

```elixir
defmodule MyApp.OrderPlacedSignal do
  use Jido.Signal,
    type: "order.placed",
    default_source: "/orders",
    schema: Zoi.object(%{
      order_id: Zoi.string(),
      total: Zoi.float()
    })
end
```

Callers use the module's own `new/1` which merges defaults and validates data before constructing the signal.

```elixir
{:ok, signal} = MyApp.OrderPlacedSignal.new(%{order_id: "ord_42", total: 29.99})
```

## Signal routing

When a signal arrives at `AgentServer`, the router maps its type to an action module. Routes come from three sources with different default priorities:

1. **Strategy routes** (priority 50+) - override everything
2. **Agent routes** (priority 0) - the standard layer
3. **Plugin routes** (priority -10) - low-priority fallbacks

Define routes on your agent with the `signal_routes` option.

```elixir
defmodule MyApp.OrderAgent do
  use Jido.Agent,
    name: "order_agent",
    signal_routes: [
      {"order.placed", MyApp.HandleOrder},
      {"order.payment.*", MyApp.ProcessPayment},
      {"audit.**", MyApp.AuditLogger}
    ]
end
```

The runtime merges all route sources into a single router sorted by priority. The first match wins.

## Pattern matching

Routes support three match types against signal types:

- **Exact** - `"order.placed"` matches only `"order.placed"`
- **Single-segment wildcard** - `"order.*.completed"` matches `"order.payment.completed"` but not `"order.payment.auth.completed"`
- **Multi-level wildcard** - `"audit.**"` matches `"audit.login.success"` and `"audit.data.export.started"`

Wildcards only apply to type segments separated by dots. Exact routes always take precedence over wildcard routes at the same priority.

## Sending signals to agents

Use `Jido.AgentServer.call/2` for synchronous dispatch that blocks until the action completes, or `cast/2` for fire-and-forget delivery.

```elixir
{:ok, pid} = Jido.AgentServer.start_link(agent: MyApp.OrderAgent)
signal = Jido.Signal.new!("order.placed", %{order_id: "ord_42"}, source: "/api")

# Synchronous - blocks, returns updated agent
{:ok, agent} = Jido.AgentServer.call(pid, signal)

# Asynchronous - returns immediately
:ok = Jido.AgentServer.cast(pid, signal)
```

`call/2` returns the updated agent struct after the action runs. `cast/2` returns `:ok` immediately and processes the signal in the background.

## Dispatch adapters

`Jido.Signal.Dispatch` sends signals to external destinations using built-in adapters.

| Adapter | Purpose |
| --- | --- |
| `:pid` | Direct delivery to a specific process |
| `:pubsub` | Broadcast via Phoenix.PubSub |
| `:logger` | Log signals through Elixir Logger |
| `:console` | Print signals to stdout |
| `:http` | Send signals as HTTP requests |
| `:webhook` | Webhook delivery with signatures |
| `:noop` | No-op adapter for testing |

Configure dispatch as a tuple of `{adapter, options}`:

```elixir
alias Jido.Signal.Dispatch

Dispatch.dispatch(signal, {:pubsub, target: :my_pubsub, topic: "orders"})
```

You can also embed dispatch instructions directly when creating a signal using the `jido_dispatch` option.

## Next steps

- [Tool use](/docs/learn/tool-use) - integrate external tools into agent workflows
- [Signals concept](/docs/concepts/signals) - authoritative reference for the signal system
- [Agent runtime concept](/docs/concepts/agent-runtime) - how AgentServer routes signals
