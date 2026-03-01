%{
  title: "Agent fundamentals",
  description: "The mental model for Jido agents: typed state, deterministic transitions, signal routing, and supervised execution.",
  category: :docs,
  order: 20,
  tags: [:docs, :learn, :fundamentals],
  draft: false
}
---
Jido agents are data, not processes. An agent is an immutable struct with schema-validated state. Actions are pure functions that return a new agent and a list of directives describing side effects. The runtime handles everything else.

## Agents as data

A `Jido.Agent` is a struct. It holds typed state, a reference to its schema, and metadata. It is not a GenServer. It does not own a mailbox, subscribe to messages, or manage timers.

This distinction matters. You can create an agent, transform it ten times in a pipeline, serialize it, send it across nodes, and deserialize it without any process infrastructure. Every transformation is a pure function call that returns a new struct.

```elixir
agent = MyApp.InventoryAgent.new()
{agent, []} = MyApp.InventoryAgent.cmd(agent, {ReceiveStock, %{sku: "A1", qty: 10}})
{agent, []} = MyApp.InventoryAgent.cmd(agent, {ReserveStock, %{sku: "A1", qty: 3}})
agent.state.stock["A1"]    # => 10
agent.state.reserved["A1"] # => 3
```

Each call to `cmd/2` returns a new agent. The previous value is unchanged. There is no hidden mutation.

## State schema

Every agent declares a schema that defines the shape, types, and defaults for its state. Jido supports Zoi schemas (recommended) and NimbleOptions-style schemas.

```elixir
defmodule MyApp.InventoryAgent do
  use Jido.Agent,
    name: "inventory_agent",
    description: "Tracks stock and reservations",
    schema: Zoi.object(%{
      status: Zoi.atom() |> Zoi.default(:idle),
      stock: Zoi.map(Zoi.integer()) |> Zoi.default(%{}),
      reserved: Zoi.map(Zoi.integer()) |> Zoi.default(%{})
    })
end
```

When you call `new/1`, the schema applies defaults and validates the initial state. `set/2` deep-merges updates into state. `validate/2` enforces strict conformance against the schema at any point.

Schemas prevent a class of bugs where state drifts into an unexpected shape. If an action returns `%{stock: "oops"}`, schema validation catches it before the bad state propagates.

## The command boundary

`cmd/2` is the single entry point for all agent transitions. It takes an agent and one or more instructions, runs them through the agent's strategy, and returns a tuple: `{updated_agent, directives}`.

```elixir
{agent, directives} = MyApp.InventoryAgent.cmd(
  agent,
  {ReceiveStock, %{sku: "A1", qty: 5}}
)
```

Three rules govern `cmd/2`:

1. It is a pure function. Same agent and instruction always produce the same result.
2. It never performs side effects. No HTTP calls, no database writes, no message sends.
3. Side effects are described as directives. The runtime decides when and whether to execute them.

This makes every transition testable without mocks, replayable for debugging, and safe to run speculatively.

## Signal routing

Signals are events that arrive at an agent. A route table maps signal types to action modules. The runtime builds a unified router from the agent's declared routes, strategy routes, and plugin routes.

```elixir
defmodule MyApp.InventoryAgent do
  use Jido.Agent,
    name: "inventory_agent",
    signal_routes: [
      {"inventory.stock.received", MyApp.ReceiveStock},
      {"inventory.reserve", MyApp.ReserveStock},
      {"inventory.release", MyApp.ReleaseReservation}
    ]
end
```

Routes match on signal type strings. You can add an optional priority (integer) or a match function for conditional routing. The runtime evaluates routes by priority and dispatches to the first match.

Wildcard routes use `*` as a suffix. A route for `"inventory.*"` matches any signal whose type starts with `"inventory."`. If no route matches, the runtime passes `{signal.type, signal.data}` to the strategy for default handling.

## Failure and supervision

`Jido.AgentServer` wraps an agent struct inside a GenServer under an OTP supervisor. The process lifecycle and the agent state lifecycle are separate concerns.

If the GenServer crashes, the supervisor restarts it. The agent struct can be reconstructed from persisted state or reinitialized from defaults. Process death does not mean domain failure.

For domain completion, update agent state directly. Set `status: :completed` or `status: :failed` in your action's return value. The process keeps running and can handle subsequent signals. This avoids races between asynchronous directive execution and process termination.

## Hands-on exercise

Build an `InventoryAgent` that tracks stock levels and reservations using three actions.

**Step 1: Define the actions.**

```elixir
defmodule MyApp.ReceiveStock do
  use Jido.Action,
    name: "inventory.receive_stock",
    schema: [
      sku: [type: :string, required: true],
      qty: [type: :integer, required: true]
    ]

  def run(params, context) do
    current = get_in(context.state, [:stock, params.sku]) || 0
    {:ok, %{stock: Map.put(context.state.stock, params.sku, current + params.qty)}}
  end
end
```

```elixir
defmodule MyApp.ReserveStock do
  use Jido.Action,
    name: "inventory.reserve_stock",
    schema: [
      sku: [type: :string, required: true],
      qty: [type: :integer, required: true]
    ]

  def run(params, context) do
    current = get_in(context.state, [:stock, params.sku]) || 0
    reserved = get_in(context.state, [:reserved, params.sku]) || 0

    if params.qty <= 0 or current - reserved < params.qty do
      {:error, :insufficient_stock}
    else
      {:ok, %{reserved: Map.put(context.state.reserved, params.sku, reserved + params.qty)}}
    end
  end
end
```

```elixir
defmodule MyApp.ReleaseReservation do
  use Jido.Action,
    name: "inventory.release_reservation",
    schema: [
      sku: [type: :string, required: true],
      qty: [type: :integer, required: true]
    ]

  def run(params, context) do
    reserved = get_in(context.state, [:reserved, params.sku]) || 0
    {:ok, %{reserved: Map.put(context.state.reserved, params.sku, max(reserved - params.qty, 0))}}
  end
end
```

**Step 2: Wire the agent.**

```elixir
defmodule MyApp.InventoryAgent do
  use Jido.Agent,
    name: "inventory_agent",
    schema: Zoi.object(%{
      status: Zoi.atom() |> Zoi.default(:idle),
      stock: Zoi.map(Zoi.integer()) |> Zoi.default(%{}),
      reserved: Zoi.map(Zoi.integer()) |> Zoi.default(%{})
    }),
    signal_routes: [
      {"inventory.stock.received", MyApp.ReceiveStock},
      {"inventory.reserve", MyApp.ReserveStock},
      {"inventory.release", MyApp.ReleaseReservation}
    ]
end
```

**Step 3: Verify.**

1. Call `cmd/2` with `{MyApp.ReceiveStock, %{sku: "A1", qty: 10}}`. Confirm `stock["A1"] == 10`.
2. Call `{MyApp.ReserveStock, %{sku: "A1", qty: 4}}` twice. The second call should return `{:error, :insufficient_stock}` because only 6 units are unreserved.
3. Call `{MyApp.ReleaseReservation, %{sku: "A1", qty: 2}}`. Confirm `reserved["A1"]` drops to 2 while `stock["A1"]` stays at 10.
4. Confirm every successful `cmd/2` returns `{agent, directives}` with an empty directives list.

## Next steps

- [Strategy](/docs/concepts/strategy) covers pluggable execution models for action dispatch
- [Plugins](/docs/concepts/plugins) explains composable capability bundles
- [Sensors](/docs/concepts/sensors) shows how external events become signals
