%{
  title: "Agent Fundamentals on the BEAM",
  description: "Foundational mental model for Jido agents: typed state, deterministic transitions, signal routing, and supervised execution.",
  category: :docs,
  order: 20,
}
---
This module establishes the core Jido mental model: agents are typed state containers, actions are deterministic transitions, and side effects are isolated as directives. You will learn how routing turns signals into actions, how the runtime executes directives, and how supervision boundaries keep processes resilient without mutating domain state.

### Overview
Jido models agents as **data first** and treats execution as a separate concern. `Jido.Agent` is a pure API that transforms state, while `Jido.AgentServer` is the GenServer runtime that interprets directives, builds signal routing, and executes effects.

### Prerequisites
Read [Build Your First Agent](/docs/learn/first-agent) to get familiar with `use Jido.Agent` and `cmd/2`. This guide assumes you can define an agent module and run a basic action.

### Mental Model
Agents as typed state containers plus behavior contracts is the core framing in Jido. An agent is an immutable struct that carries validated state plus an execution contract (`cmd/2`, `signal_routes/1`, and optional pure callbacks).

Immutable transitions for debuggability and replayability follow from `cmd/2` always returning a **new** agent and a list of directives. Directives describe side effects but never mutate state, giving you isolation of side effects from domain transitions while the runtime handles process work.

Differentiate process lifecycle from agent state lifecycle. A GenServer may restart or continue running, but completion, failure, and progress live in agent state (for example `status: :completed`).

### State Schema
A schema defines the shape and defaults for agent state. Jido supports NimbleOptions-style schemas and Zoi schemas, with Zoi recommended for new code.

```elixir
defmodule InventoryAgent do
  use Jido.Agent,
    name: "inventory_agent",
    description: "Tracks stock and reservations.",
    schema: Zoi.object(%{
      status: Zoi.atom() |> Zoi.default(:idle),
      stock: Zoi.map(Zoi.integer()) |> Zoi.default(%{}),
      reserved: Zoi.map(Zoi.integer()) |> Zoi.default(%{})
    })
end
```

`new/1` builds initial state by applying schema defaults, then strategy initialization runs to set any strategy-managed fields. `set/2` deep-merges updates into state, and `validate/2` lets you enforce strict schema conformance.

### Signal Routing
Signals are routed to actions by the runtime, not by the agent. `Jido.AgentServer` builds a unified router from strategy routes, agent routes, and plugin routes, then dispatches each signal to the best matching action.

Signal route tables mapping events to action modules keep signal naming explicit and predictable. Routes can include optional match functions and priorities, and they are normalized into a single router by the runtime.

```elixir
defmodule InventoryAgent do
  use Jido.Agent,
    name: "inventory_agent",
    signal_routes: [
      {"inventory.stock.received", Inventory.ReceiveStock},
      {"inventory.reserve", Inventory.ReserveStock},
      {"inventory.release", Inventory.ReleaseReservation, 5},
      {"inventory.*", fn signal -> signal.data["sku"] != nil end, Inventory.ReceiveStock, -5}
    ]
end
```

If no route matches, the runtime falls back to `{signal.type, signal.data}` as the action input for the strategy to interpret. This keeps unmatched signals explicit while preserving deterministic behavior.

### Deterministic Execution
`cmd/2` is a pure function: given the same agent and action, it always returns the same updated agent and directives. `Jido.Agent` normalizes instructions, executes them through the selected strategy, and then applies `on_after_cmd/3` as a final pure transformation.

Side effects are never applied inside `cmd/2`. Instead, actions return state diffs and the strategy returns directives, which the runtime can execute later or not at all.

```elixir
agent = InventoryAgent.new(state: %{stock: %{"sku-1" => 10}})

{agent2, directives} = InventoryAgent.cmd(
  agent,
  {Inventory.ReceiveStock, %{sku: "sku-1", qty: 5}}
)

# agent2.state.stock["sku-1"] == 15
# directives == []
```

### Failure and Supervision
Each agent runs inside a `Jido.AgentServer` GenServer under a supervisor. If the process crashes, supervision can restart it, but your domain completion status is still a state concern.

For normal completion, update agent state (for example `status: :completed`) instead of stopping the process. This makes the process lifecycle distinct from the agent state lifecycle and avoids races with asynchronous directive execution.

### Hands-on Exercise
InventoryAgent exercise with schema, routes, and guards. You will build an `InventoryAgent` that tracks stock and reservations with deterministic transitions, then drive it using signal routes.

Step-by-step:
1. Define the agent schema with `stock` and `reserved` maps keyed by SKU.
2. Define actions `ReceiveStock`, `ReserveStock`, and `ReleaseReservation` with guards for invalid quantities or insufficient stock.
3. Wire signal routes that map inventory signals to those actions.
4. Run commands and confirm the agent always returns a new state plus directives.

```elixir
defmodule Inventory.ReceiveStock do
  use Jido.Action,
    name: "inventory.receive_stock",
    schema: [
      sku: [type: :string, required: true],
      qty: [type: :integer, required: true]
    ]

  def run(%{sku: sku, qty: qty}, %{state: state}) do
    current = get_in(state, [:stock, sku]) || 0
    {:ok, %{stock: Map.put(state.stock, sku, current + qty)}}
  end
end

defmodule Inventory.ReserveStock do
  use Jido.Action,
    name: "inventory.reserve_stock",
    schema: [
      sku: [type: :string, required: true],
      qty: [type: :integer, required: true]
    ]

  def run(%{sku: sku, qty: qty}, %{state: state}) do
    current = get_in(state, [:stock, sku]) || 0
    reserved = get_in(state, [:reserved, sku]) || 0

    if qty <= 0 or current - reserved < qty do
      {:error, :insufficient_stock}
    else
      {:ok, %{reserved: Map.put(state.reserved, sku, reserved + qty)}}
    end
  end
end
```

```elixir
defmodule Inventory.ReleaseReservation do
  use Jido.Action,
    name: "inventory.release_reservation",
    schema: [
      sku: [type: :string, required: true],
      qty: [type: :integer, required: true]
    ]

  def run(%{sku: sku, qty: qty}, %{state: state}) do
    reserved = get_in(state, [:reserved, sku]) || 0
    new_reserved = max(reserved - qty, 0)
    {:ok, %{reserved: Map.put(state.reserved, sku, new_reserved)}}
  end
end
```

```elixir
defmodule InventoryAgent do
  use Jido.Agent,
    name: "inventory_agent",
    schema: Zoi.object(%{
      status: Zoi.atom() |> Zoi.default(:idle),
      stock: Zoi.map(Zoi.integer()) |> Zoi.default(%{}),
      reserved: Zoi.map(Zoi.integer()) |> Zoi.default(%{})
    }),
    signal_routes: [
      {"inventory.stock.received", Inventory.ReceiveStock},
      {"inventory.reserve", Inventory.ReserveStock},
      {"inventory.release", Inventory.ReleaseReservation}
    ]
end
```

### Verification Steps
1. Create a new agent and call `cmd/2` with `{Inventory.ReceiveStock, %{sku: "sku-1", qty: 10}}`, then confirm stock increments by 10.
2. Call `{Inventory.ReserveStock, %{sku: "sku-1", qty: 4}}` twice and confirm the second call returns an error from the action.
3. Call `{Inventory.ReleaseReservation, %{sku: "sku-1", qty: 2}}` and confirm `reserved["sku-1"]` decreases while stock stays unchanged.
4. Confirm that each command returns `{agent, directives}` and that directives are empty for these actions.

### Related Reading
- [Agents](/docs/concepts/agents)
- [Agent Runtime](/docs/concepts/agent-runtime)
- [Actions and Validation](/docs/learn/actions-validation)

---
<sub>Generated by Jido Documentation Writer Bot | Run ID: `80a001ad84c8`</sub>