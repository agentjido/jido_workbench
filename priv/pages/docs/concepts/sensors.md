%{
  title: "Sensors",
  description: "Stateless modules that bridge external events into Jido's signal layer.",
  category: :docs,
  order: 95,
  tags: [:docs, :concepts],
  draft: false
}
---
Sensors connect the external world to your agents. They observe sources like HTTP webhooks, message queues, database changes, system metrics, and timers, then transform those raw events into typed signals. Every sensor is a stateless behaviour module that defines initialization logic and event handling. The runtime execution happens in a separate `SensorServer` process.

## What sensors solve

Agents need to react to the outside world, but coupling them directly to external sources creates fragile systems. Polling a metrics endpoint inside an agent mixes concerns. Parsing webhook payloads in a signal router scatters transformation logic.

Sensors give you a single, focused boundary for this work. Each sensor owns the translation from one external source into the signal vocabulary your agents understand. When a webhook format changes or a queue protocol evolves, you update one sensor module instead of touching agent logic.

## Anatomy of a sensor

Define a sensor with `use Jido.Sensor` and provide metadata that describes it.

```elixir
defmodule MyApp.TemperatureSensor do
  use Jido.Sensor,
    name: "temperature_sensor",
    description: "Monitors temperature readings",
    schema: Zoi.object(%{
      unit: Zoi.string(),
      threshold: Zoi.number()
    })

  @impl true
  def init(config, _context) do
    {:ok, %{unit: config.unit, threshold: config.threshold}}
  end

  @impl true
  def handle_event({:reading, value}, state) do
    signal = Jido.Signal.new!(%{
      source: "temperature_sensor",
      type: "temperature.reading",
      data: %{value: value, unit: state.unit}
    })
    {:ok, state, [{:emit, signal}]}
  end
end
```

Three options go into the `use` macro:

- **`name`** - A unique identifier for the sensor. Must contain only letters, numbers, and underscores.
- **`description`** - A human-readable summary of what the sensor monitors.
- **`schema`** - A `Zoi` schema that validates configuration passed to `init/2` at startup.

The macro generates helper functions like `name/0`, `description/0`, `schema/0`, and `spec/0` automatically.

## Callbacks

Every sensor implements two required callbacks and one optional callback.

### `init/2`

Called when the sensor starts. Receives the validated configuration map and a runtime context map. Returns initial state and optional startup directives.

```elixir
def init(config, _context) do
  {:ok, %{metric: config.metric, last_value: nil},
   [{:schedule, 5_000}]}
end
```

The return values are `{:ok, state}`, `{:ok, state, directives}`, or `{:error, reason}`.

### `handle_event/2`

Called when the sensor receives an event from its connected source. You inspect the event, build signals, update state, and return directives that tell the runtime what to do next.

```elixir
def handle_event(:tick, state) do
  signal = Jido.Signal.new!(%{
    source: "/sensor/heartbeat",
    type: "heartbeat.tick"
  })
  {:ok, state, [{:emit, signal}, {:schedule, 1_000}]}
end
```

The return values follow the same shape as `init/2`.

### `terminate/2`

Called on shutdown. The default implementation returns `:ok`. Override it only when you need to clean up resources.

## Sensor directives

Callbacks return a list of directives that instruct the runtime to perform actions on behalf of the sensor. These are distinct from agent directives.

| Directive | Purpose |
| --- | --- |
| `{:emit, signal}` | Emit a signal immediately to the connected agent |
| `{:schedule, ms}` | Schedule a `:tick` event after the given interval |
| `{:schedule, ms, payload}` | Schedule a custom event after the given interval |
| `{:connect, adapter}` | Connect to an external source via an adapter |
| `{:connect, adapter, opts}` | Connect with adapter-specific options |
| `{:disconnect, adapter}` | Disconnect from a source |
| `{:subscribe, topic}` | Subscribe to a topic or pattern |
| `{:unsubscribe, topic}` | Unsubscribe from a topic |

You can combine directives freely. A polling sensor typically returns `{:emit, signal}` and `{:schedule, interval}` together so it emits data and re-arms itself in one step.

```elixir
def handle_event(:tick, state) do
  value = fetch_current_metric(state.metric)
  signal = Jido.Signal.new!(%{
    source: "metric_sensor",
    type: "metric.updated",
    data: %{value: value, previous: state.last_value}
  })
  {:ok, %{state | last_value: value},
   [{:emit, signal}, {:schedule, 10_000}]}
end
```

## Sensors in the architecture

Sensors sit at the edge of the Jido system. They form the input boundary where external events enter the signal layer.

The flow is: **Sensor** receives a raw event, transforms it into a typed **Signal**, and emits it. The runtime routes that signal to the appropriate **Agent**, which processes it through actions and produces directives. This pipeline keeps each layer focused on a single responsibility.

Because sensors are stateless behaviour modules, they are easy to test in isolation. Pass an event to `handle_event/2`, assert on the returned signals and directives. No process lifecycle or external connections required.

## Next steps

- [Signals](/docs/concepts/signals) - understand the typed envelopes that sensors produce
- [Agents](/docs/concepts/agents) - learn how agents consume signals and transition state
- [Directives](/docs/concepts/directives) - explore the effect system that sensors and agents share
