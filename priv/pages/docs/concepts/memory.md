%{
  title: "Memory",
  description: "The mutable cognitive substrate where agents store current beliefs, goals, and working data.",
  category: :docs,
  order: 120,
  tags: [:docs, :concepts],
  draft: false
}
---
## What memory solves

Agents need a structured place for their current state of mind: beliefs about the world, active goals, working data they accumulate during operation. Agent state (via schema) holds domain data, but cognitive structures need their own namespace. Memory provides named, typed partitions inside agent state under the reserved key `:__memory__`.

Without Memory, cognitive data gets mixed into the agent's domain state. You end up storing temperature readings, task lists, and location beliefs alongside order totals and user profiles. This makes it hard to reason about what the agent "knows" versus what it "manages." Memory gives cognitive data a dedicated home with per-space revision tracking.

Memory is created on demand. A bare agent carries no memory overhead until you call `ensure/2`. This keeps lightweight agents fast while giving complex agents the cognitive infrastructure they need.

## Memory vs thread

Thread and Memory are both pillars of agent cognition, but they serve different purposes.

Thread records what happened. It is an append-only log of interactions, commands, and events. You never overwrite a thread entry. Thread answers the question "what occurred?"

Memory represents what the agent currently believes. It is mutable and overwritable. When the temperature changes, you update the `:world` space. When a task completes, you remove it from `:tasks`. Memory answers the question "what do I know right now?"

Together with Strategy (execution control), these three pillars form the cognitive architecture of a Jido agent.

## Memory structure

`Jido.Memory` is a Zoi-validated struct with the following fields:

| Field | Type | Description |
| --- | --- | --- |
| `id` | string | Unique identifier, prefixed `mem_` |
| `rev` | integer | Container-level monotonic revision |
| `spaces` | map | Named `Space` structs |
| `created_at` | integer | Creation timestamp in milliseconds |
| `updated_at` | integer | Last update timestamp in milliseconds |
| `metadata` | map | Arbitrary metadata |

`Memory.new/1` initializes two reserved spaces: `:world` (key-value map) and `:tasks` (ordered list).

```elixir
alias Jido.Memory

memory = Memory.new()
memory.id        #=> "mem_cuid..."
memory.rev       #=> 0
memory.spaces.world   #=> %Space{data: %{}, rev: 0}
memory.spaces.tasks   #=> %Space{data: [], rev: 0}
```

## Spaces

`Jido.Memory.Space` is the unit of memory. Each space holds either a map or a list in its `data` field, tracks its own revision counter, and carries optional metadata.

| Field | Type | Description |
| --- | --- | --- |
| `data` | map or list | Space contents |
| `rev` | integer | Per-space revision, increments on mutation |
| `metadata` | map | Space-level metadata |

Create spaces with `Space.new_kv/1` for key-value data or `Space.new_list/1` for ordered items. Use `Space.map?/1` and `Space.list?/1` to check the data type for dispatch.

```elixir
alias Jido.Memory.Space

world = Space.new_kv()
Space.map?(world)    #=> true

tasks = Space.new_list()
Space.list?(tasks)   #=> true
```

## Reserved spaces

Every memory starts with two reserved spaces that cannot be deleted.

**`:world`** is a key-value map for general beliefs about the environment. Store temperature readings, GPS coordinates, configuration flags, or any fact the agent needs to track.

**`:tasks`** is an ordered list for work items. Append tasks, process them in order, and remove completed entries.

You can add custom spaces for domain-specific cognitive structures. Reserved spaces raise an `ArgumentError` if you attempt to delete them.

## Agent integration

`Jido.Memory.Agent` provides helper functions for managing memory inside agent state. All operations auto-initialize memory if missing and bump both space and container revisions on mutation.

```elixir
alias Jido.Memory.Agent, as: MemoryAgent

agent = MyApp.WeatherAgent.new()

agent = MemoryAgent.put_in_space(agent, :world, :temperature, 22)
agent = MemoryAgent.put_in_space(agent, :world, :location, "Portland")

MemoryAgent.get_in_space(agent, :world, :temperature)
#=> 22
```

### Map space operations

`put_in_space/4` sets a key-value pair. `get_in_space/4` retrieves a value with an optional default. `delete_from_space/3` removes a key. All three validate that the target space holds map data.

### List space operations

`append_to_space/3` adds an item to the end of a list space.

```elixir
agent = MemoryAgent.append_to_space(agent, :tasks, %{
  id: "t1",
  text: "Check sensor array"
})

agent = MemoryAgent.append_to_space(agent, :tasks, %{
  id: "t2",
  text: "Report status"
})
```

### Space management

`ensure_space/3` creates a space with default data if it does not already exist. `put_space/3` replaces a space entirely. `update_space/3` applies a transformation function. `delete_space/2` removes non-reserved spaces.

```elixir
agent = MemoryAgent.ensure_space(agent, :sensors, %{})
agent = MemoryAgent.put_in_space(agent, :sensors, :lidar, :active)

MemoryAgent.has_space?(agent, :sensors)
#=> true
```

## Plugin integration

`Jido.Memory.Plugin` is a default singleton plugin included in every agent. It declares ownership of the `:__memory__` state key and is initialized lazily. The plugin mounts with `nil` state and does not allocate memory until you call `MemoryAgent.ensure/2` or any operation that triggers it.

Disable it per-agent if you do not need memory:

```elixir
defmodule MyApp.StatelessAgent do
  use Jido.Agent,
    name: "stateless_agent",
    default_plugins: %{__memory__: false}
end
```

The default plugin keeps memory in-process only. For external persistence (ETS, database), implement a custom memory plugin with `on_checkpoint/2` and `on_restore/2` callbacks.

## Concurrency control

Every space tracks its own revision counter independently from the container. When you update a space, both the space `rev` and the container `rev` increment. This enables fine-grained conflict detection.

You can compare space revisions to detect concurrent modifications at the space level rather than locking the entire memory container. The container-level `rev` tracks total mutations across all spaces, giving you a single counter for coarse-grained change detection.

```elixir
agent = MemoryAgent.put_in_space(agent, :world, :temperature, 22)

memory = MemoryAgent.get(agent)
memory.rev                    #=> 2
memory.spaces.world.rev       #=> 1
memory.spaces.tasks.rev       #=> 0
```

The `:tasks` space revision stays at zero because it was not touched. The `:world` space incremented once. The container revision reflects the total number of mutations since creation.

## Next steps

- [Plugins](/docs/concepts/plugins) - how memory integrates as a default singleton plugin
- [Strategy](/docs/concepts/strategy) - the third cognitive pillar controlling action execution
- [Agents](/docs/concepts/agents) - the full agent contract and state model
