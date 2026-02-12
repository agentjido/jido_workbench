%{
  title: "Demand Tracker Agent",
  description: "A Jido agent that tracks listing demand with boost/cool/decay actions. Demonstrates Directives — the agent's mechanism for requesting side effects like emitting domain events (Emit) and scheduling future signals (Schedule).",
  tags: ["directives", "emit", "schedule", "signals", "state"],
  category: :core,
  emoji: "📊",
  source_files: [
    "lib/agent_jido/demos/demand/demand_tracker_agent.ex",
    "lib/agent_jido/demos/demand/actions/boost_action.ex",
    "lib/agent_jido/demos/demand/actions/cool_action.ex",
    "lib/agent_jido/demos/demand/actions/decay_action.ex",
    "lib/agent_jido/demos/demand/actions/toggle_auto_decay_action.ex",
    "lib/agent_jido_web/examples/demand_tracker_agent_live.ex"
  ],
  live_view_module: "AgentJidoWeb.Examples.DemandTrackerAgentLive",
  difficulty: :intermediate,
  sort_order: 20
}
---

## What you'll learn

- How Jido Directives let actions request side effects
- The Emit directive for publishing domain events
- The Schedule directive for delayed signals and self-rescheduling loops
- How to separate state updates from side effects

## How it works

The counter example shows pure state changes — every action returns `{:ok, new_state}` and nothing else happens. The demand tracker introduces **Directives**: instructions that actions return alongside state updates. The agent runtime processes these directives after the action completes, keeping side effects out of action logic.

This example uses two directive types: **Emit** (publish a domain event) and **Schedule** (deliver a signal after a delay).

### The Agent

The demand tracker declares its state schema and signal routes:

```elixir
use Jido.Agent,
  name: "demand_tracker",
  schema: [
    listing_id: [type: :string, default: "demo-listing"],
    demand: [type: :integer, default: 50],
    ticks: [type: :integer, default: 0],
    auto_decay_enabled: [type: :boolean, default: false]
  ]

def signal_routes(_ctx) do
  [
    {"listing.demand.boost", BoostAction},
    {"listing.demand.cool", CoolAction},
    {"listing.demand.tick", DecayAction},
    {"listing.demand.auto_decay.toggle", ToggleAutoDecayAction}
  ]
end
```

### Actions with Directives

`BoostAction` is the simplest example. It updates demand **and** returns an Emit directive with a domain event signal:

```elixir
def run(%{amount: amount}, context) do
  current_demand = Map.get(context.state, :demand, 50)
  new_demand = min(current_demand + amount, 100)

  emit_signal = Signal.new!("listing.demand.changed", %{...}, source: "/demo/demand-tracker")

  {:ok, %{demand: new_demand, last_updated_at: now}, Directive.emit(emit_signal)}
end
```

The three-element tuple `{:ok, state_changes, directives}` is the key pattern. Compare this with the counter's two-element `{:ok, state_changes}` — the third element is what makes directives work.

### The Schedule Directive

`ToggleAutoDecayAction` demonstrates the Schedule directive. When auto-decay is enabled, it schedules a future `listing.demand.tick` signal:

```elixir
tick_signal = Signal.new!("listing.demand.tick", %{}, source: "/demo/demand-tracker")

{:ok, %{auto_decay_enabled: true}, [Directive.schedule(10_000, tick_signal)]}
```

When that tick signal arrives 10 seconds later, `DecayAction` runs, decays the demand, and — if auto-decay is still enabled — schedules the next tick. This creates a **self-sustaining decay loop** using only declarative directives:

```elixir
# In DecayAction, after performing the decay:
if auto_enabled do
  tick_signal = Signal.new!("listing.demand.tick", %{}, source: "/demo/demand-tracker")
  [Directive.schedule(10_000, tick_signal) | directives]
else
  directives
end
```

When auto-decay is toggled off, `auto_decay_enabled` becomes `false`. The next scheduled tick still arrives and `DecayAction` still runs — but it sees `auto_decay_enabled: false` and doesn't schedule another tick, breaking the loop cleanly.

### State vs Side Effects

The clean separation is the point. Actions return pure state changes plus directive instructions. They never call external services, publish events, or set timers directly. The agent runtime handles all of that after the action completes.

This makes actions testable — you can assert on state changes and returned directives without mocking anything. It also makes the system predictable: the action's return value fully describes what should happen.

## Key concepts

**Directives are declarative.** Actions don't perform side effects directly — they return instructions. The runtime decides how and when to execute them.

**Emit publishes domain events.** Other parts of the system can subscribe to `listing.demand.changed` signals and react — logging, notifications, analytics, or triggering other agents.

**Schedule enables temporal patterns.** `Directive.schedule(delay_ms, signal)` delivers a signal after a delay. Combined with self-rescheduling, this creates recurring behaviors without external schedulers.

**Self-rescheduling is a pattern, not a primitive.** The decay loop isn't built into the framework — it emerges from DecayAction choosing to schedule the next tick. This gives the action full control: it can change the interval, skip a tick, or stop the loop based on current state.
