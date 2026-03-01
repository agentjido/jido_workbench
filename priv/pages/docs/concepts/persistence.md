%{
  title: "Persistence",
  description: "How agents survive restarts through state snapshots, thread journals, and rehydration.",
  category: :docs,
  order: 125,
  tags: [:docs, :concepts],
  draft: false
}
---
## What persistence solves

In-memory agents vanish when a process crashes or a node restarts. Any accumulated state, conversation history, or workflow progress disappears with the process. You need a way to snapshot agent state and reconstruct it later without losing data.

Jido separates persistence into two concerns. `Jido.Storage` is a behaviour that defines how data reaches durable storage. `Jido.Persist` is the module that enforces correctness invariants on top of any storage adapter. This separation means you can swap storage backends without changing your persistence logic.

## The Storage behaviour

`Jido.Storage` defines six callbacks organized into two groups.

### Checkpoints

Checkpoints use key-value overwrite semantics. Each call replaces the previous value for that key.

```elixir
@callback get_checkpoint(key :: String.t(), opts :: keyword()) ::
            {:ok, map()} | :not_found | {:error, term()}

@callback put_checkpoint(key :: String.t(), data :: map(), opts :: keyword()) ::
            :ok | {:error, term()}

@callback delete_checkpoint(key :: String.t(), opts :: keyword()) ::
            :ok | {:error, term()}
```

### Journals

Journals are append-only thread entries. New entries add to the existing log rather than replacing it.

```elixir
@callback load_thread(thread_id :: String.t(), opts :: keyword()) ::
            {:ok, thread :: map()} | :not_found | {:error, term()}

@callback append_thread(thread_id :: String.t(), entries :: list(), opts :: keyword()) ::
            {:ok, updated_thread :: map()} | {:error, term()}

@callback delete_thread(thread_id :: String.t(), opts :: keyword()) ::
            :ok | {:error, term()}
```

The `append_thread/3` callback accepts an `:expected_rev` option for optimistic concurrency control. If the stored thread's revision does not match, the call returns `{:error, :conflict}`.

## Built-in adapters

| Adapter | Durability | Use case |
|---|---|---|
| `Jido.Storage.ETS` | Ephemeral | Development and testing |
| `Jido.Storage.File` | Durable (directory-based) | Single-node persistence |

Configure an adapter as a tuple of module and options:

```elixir
storage = {Jido.Storage.ETS, []}

storage = {Jido.Storage.File, path: "priv/jido"}
```

## Hibernate and thaw

`Jido.Persist` orchestrates the full lifecycle of saving and restoring agents. It calls through to your storage adapter while enforcing invariants that keep checkpoints and threads consistent.

### Hibernate flow

When you call `Jido.Persist.hibernate/2`, the following steps execute in order:

1. Extract the thread from `agent.state[:__thread__]`
2. Flush only missing thread entries via `append_thread/3`, diffing against the stored revision
3. Call `agent_module.checkpoint/2` if the agent implements it, otherwise use default serialization
4. Remove `:__thread__` from the checkpoint state and store a thread pointer (`%{id: id, rev: rev}`) instead
5. Write the checkpoint via `put_checkpoint/3`

```elixir
{:ok, checkpoint} = Jido.Persist.hibernate(agent, storage)
```

The thread pointer separation is the critical invariant. Checkpoints stay small regardless of how long the thread grows. A thread with 10,000 entries produces the same checkpoint size as one with 10 entries.

### Thaw flow

When you call `Jido.Persist.thaw/3`, the restore sequence runs:

1. Load the checkpoint via `get_checkpoint/2`
2. Call `agent_module.restore/2` if implemented, otherwise use default deserialization
3. If the checkpoint contains a thread pointer, load the thread and verify its revision matches the pointer
4. Attach the thread to the agent's state

```elixir
{:ok, agent} = Jido.Persist.thaw(MyApp.WorkflowAgent, agent_id, storage)
```

If the thread revision does not match the pointer, thaw returns an error. This catches cases where external processes modified the thread after the checkpoint was written.

## Checkpoint structure

A checkpoint contains five fields:

```elixir
%{
  version: 1,
  agent_module: MyApp.WorkflowAgent,
  id: "agent_abc123",
  state: %{score: 42, status: :active},
  thread: %{id: "thread_xyz789", rev: 42}
}
```

The `state` field holds the full agent state without `:__thread__`. The `thread` field is a pointer only, never the full thread data. If the agent has no thread, this field is `nil`.

This design means you can store thousands of checkpoints without duplicating thread content across them.

## Optimistic concurrency

Thread operations support optimistic concurrency through the `:expected_rev` option on `append_thread/3`. This prevents two writers from silently overwriting each other's entries.

```elixir
{:ok, thread} = storage_mod.append_thread(
  thread_id,
  new_entries,
  expected_rev: 41
)
```

If another process advanced the thread past revision 41 before your write lands, the call returns `{:error, :conflict}`. Persist handles this gracefully during hibernate: if the stored revision is greater than or equal to the local revision, the conflict resolves silently because another writer already flushed the same or newer entries.

## Custom agent callbacks

Agents can optionally implement two callbacks to control how their state serializes:

```elixir
defmodule MyApp.WorkflowAgent do
  use Jido.Agent,
    name: "workflow_agent",
    schema: [
      score: [type: :integer, default: 0],
      db_conn: [type: :any]
    ]

  def checkpoint(agent, _ctx) do
    data = Map.drop(agent.state, [:db_conn])
    {:ok, data}
  end

  def restore(checkpoint_data, _ctx) do
    state = Map.put(checkpoint_data, :db_conn, MyApp.Repo.connection())
    {:ok, state}
  end
end
```

Use `checkpoint/2` to strip non-serializable values like database connections or process references. Use `restore/2` to rehydrate those values when the agent comes back.

If you do not implement these callbacks, Persist uses default serialization that captures the full agent state minus the thread.

## Implementing a custom adapter

To build your own storage backend, implement the six `Jido.Storage` callbacks:

```elixir
defmodule MyApp.RedisStorage do
  @behaviour Jido.Storage

  @impl true
  def get_checkpoint(key, _opts), do: # fetch from Redis

  @impl true
  def put_checkpoint(key, data, _opts), do: # write to Redis

  @impl true
  def delete_checkpoint(key, _opts), do: # delete from Redis

  @impl true
  def load_thread(thread_id, _opts), do: # load thread entries

  @impl true
  def append_thread(thread_id, entries, opts) do
    expected = Keyword.get(opts, :expected_rev)
    # check revision, append entries, return updated thread
  end

  @impl true
  def delete_thread(thread_id, _opts), do: # delete thread
end
```

Each callback receives an `opts` keyword list for adapter-specific configuration. The adapter is responsible for honoring `:expected_rev` in `append_thread/3` and returning `{:error, :conflict}` when the check fails.

## Next steps

- [Agents](/docs/concepts/agents) - understand the agent struct that persistence operates on
- [Agent runtime](/docs/concepts/agent-runtime) - see how AgentServer manages agent lifecycle and can trigger hibernate/thaw
- [Signals](/docs/concepts/signals) - learn how signals flow through the system that threads record
