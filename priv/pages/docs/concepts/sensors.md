%{
  title: "Sensors",
  description: "GenServer-backed modules that bridge external events into Jido's signal layer.",
  category: :docs,
  order: 95,
  tags: [:docs, :concepts],
  draft: false
}
---
Sensors connect the external world to your agents. They observe sources like PubSub topics, HTTP webhooks, message queues, database changes, and timers, then transform those raw events into typed signals.

Under the hood, a sensor is a GenServer. The `Jido.Sensor.Runtime` process wraps your sensor module, manages its lifecycle, and implements the standard GenServer callbacks - `init/1`, `handle_info/2`, `handle_cast/2`, and `terminate/2`. Your sensor module defines the behavior; the runtime provides the process.

## What sensors solve

Agents need to react to the outside world, but coupling them directly to external sources creates fragile systems. Polling a metrics endpoint inside an agent mixes concerns. Parsing webhook payloads in a signal router scatters transformation logic.

Sensors give you a single, focused boundary for this work. Each sensor owns the translation from one external source into the signal vocabulary your agents understand. When a webhook format changes or a queue protocol evolves, you update one sensor module instead of touching agent logic.

## Defining a sensor

Define a sensor with `use Jido.Sensor` and provide metadata. This example listens to a Phoenix.PubSub topic for new orders.

```elixir
defmodule MyApp.OrderSensor do
  use Jido.Sensor,
    name: "order_sensor",
    description: "Listens for new orders from PubSub",
    schema: Zoi.object(%{
      pubsub: Zoi.atom(),
      topic: Zoi.string()
    })

  @impl true
  def init(config, _context) do
    Phoenix.PubSub.subscribe(config.pubsub, config.topic)
    {:ok, %{pubsub: config.pubsub, topic: config.topic}}
  end

  @impl true
  def handle_event({:order_placed, order}, state) do
    signal = Jido.Signal.new!(
      "order.placed",
      %{order_id: order.id, total: order.total, customer_id: order.customer_id},
      source: "/sensor/orders"
    )
    {:ok, state, [{:emit, signal}]}
  end

  def handle_event(_unknown, state) do
    {:ok, state}
  end
end
```

Three options go into the `use` macro:

- **`name`** - A unique identifier for the sensor. Must contain only letters, numbers, and underscores.
- **`description`** - A human-readable summary of what the sensor monitors.
- **`schema`** - A `Zoi` schema that validates configuration passed to `init/2` at startup.

## Callbacks

### `init/2`

Called when the sensor starts. Receives the validated configuration map and a runtime context map. Returns initial state and optional startup directives.

In the order sensor, `init/2` subscribes to the PubSub topic. Because `Sensor.Runtime` is a GenServer, PubSub broadcast messages arrive as `handle_info` messages, which the runtime forwards to your `handle_event/2` callback.

The return values are `{:ok, state}`, `{:ok, state, directives}`, or `{:error, reason}`.

### `handle_event/2`

Called when the sensor receives an event from its connected source. You inspect the event, build signals, update state, and return directives that tell the runtime what to do next.

The order sensor pattern-matches on `{:order_placed, order}` and builds a typed signal from the raw PubSub payload. Unrecognized events return `{:ok, state}` with no directives.

### `terminate/2`

Called on shutdown. The default implementation returns `:ok`. Override it only when you need to clean up resources.

## Sensor directives

Callbacks return a list of directives that instruct the runtime to perform actions on behalf of the sensor. These are distinct from agent directives.

| Directive | Purpose |
| --- | --- |
| `{:emit, signal}` | Emit a signal to the connected agent |
| `{:schedule, ms}` | Schedule a `:tick` event after the given interval |
| `{:schedule, ms, payload}` | Schedule a custom event after the given interval |

You can combine directives freely. A polling sensor returns `{:emit, signal}` and `{:schedule, interval}` together so it emits data and re-arms itself in one step.

## Connecting to an agent

Start the agent and sensor in your application supervision tree. The sensor's `context` includes the `agent_ref` - the pid or name of the `AgentServer` that should receive the emitted signals.

```elixir
defmodule MyApp.OrderAgent do
  use Jido.Agent,
    name: "order_agent",
    schema: Zoi.object(%{
      orders_processed: Zoi.integer() |> Zoi.default(0),
      last_order_id: Zoi.string() |> Zoi.optional()
    })
end

defmodule MyApp.ProcessOrderAction do
  use Jido.Action,
    name: "process_order",
    schema: Zoi.object(%{
      order_id: Zoi.string(),
      total: Zoi.float(),
      customer_id: Zoi.string()
    })

  @impl true
  def run(params, _context) do
    {:ok, %{
      orders_processed: params.orders_processed + 1,
      last_order_id: params.order_id
    }}
  end
end
```

Wire them together in your supervision tree:

```elixir
children = [
  {Jido.AgentServer, agent: MyApp.OrderAgent, id: :order_agent},
  {Jido.Sensor.Runtime,
    sensor: MyApp.OrderSensor,
    config: %{pubsub: MyApp.PubSub, topic: "orders"},
    context: %{agent_ref: :order_agent}}
]

Supervisor.start_link(children, strategy: :one_for_one)
```

When something in your application broadcasts an order:

```elixir
Phoenix.PubSub.broadcast(MyApp.PubSub, "orders", {:order_placed, order})
```

The sensor receives the broadcast, transforms it into a typed `"order.placed"` signal, and emits it to the agent. The `AgentServer` routes the signal through its signal router and executes the matching action.

## Injecting events directly

You can push events into a sensor programmatically using `Jido.Sensor.Runtime.event/2`. This is useful for testing or for sources that don't use PubSub.

```elixir
Jido.Sensor.Runtime.event(sensor_pid, {:order_placed, order})
```

## Testing sensors

Because sensors define pure callbacks, you can test them in isolation without starting any processes.

```elixir
test "order sensor emits signal for placed orders" do
  {:ok, state} = MyApp.OrderSensor.init(
    %{pubsub: MyApp.PubSub, topic: "orders"}, %{}
  )

  order = %{id: "ord_123", total: 99.99, customer_id: "cus_456"}
  {:ok, _state, directives} = MyApp.OrderSensor.handle_event(
    {:order_placed, order}, state
  )

  assert [{:emit, signal}] = directives
  assert signal.type == "order.placed"
  assert signal.data.order_id == "ord_123"
end
```

## Next steps

- [Signals](/docs/concepts/signals) - understand the typed envelopes that sensors produce
- [Agents](/docs/concepts/agents) - learn how agents consume signals and transition state
- [Agent runtime](/docs/concepts/agent-runtime) - see how AgentServer routes signals from sensors to actions
