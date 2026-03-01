%{
  title: "Threads",
  description: "The append-only interaction log that records what happened during agent operation.",
  category: :docs,
  order: 115,
  tags: [:docs, :concepts],
  draft: false
}
---
## What threads solve

Agent systems need a canonical record of "what happened." Without one, debugging multi-step workflows means reconstructing history from scattered logs, process mailboxes, and return values. The problem compounds when multiple actions execute in sequence or when you need to replay a conversation.

`Jido.Thread` provides an immutable, append-only, provider-agnostic interaction log. Every append returns a new struct, so you always have a consistent snapshot of the full history. Because Thread carries no LLM-specific formatting, the same log works whether you project it to OpenAI, Anthropic, or a custom provider.

## Thread structure

A Thread is a Zoi-validated struct with these fields:

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier, prefixed `thread_` |
| `rev` | integer | Monotonic revision counter, increments on each append |
| `entries` | list | Ordered list of `Entry` structs |
| `created_at` | integer | Creation timestamp in milliseconds |
| `updated_at` | integer | Last update timestamp in milliseconds |
| `metadata` | map | Arbitrary metadata you attach at creation |
| `stats` | map | Cached aggregates like `%{entry_count: 0}` |

The `rev` field gives you a cheap way to detect whether a thread has changed since you last inspected it. The `stats` map avoids repeated traversals for common queries.

## Entry anatomy

Each entry in a thread is a `Jido.Thread.Entry` struct:

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique entry identifier |
| `seq` | integer | Monotonic sequence within the thread |
| `at` | integer | Timestamp in milliseconds |
| `kind` | atom | Entry type, open-ended |
| `payload` | map | Kind-specific data |
| `refs` | map | Cross-references to other primitives |

Kinds are not restricted to a fixed set. Recommended kinds include `:message`, `:tool_call`, `:tool_result`, `:signal_in`, `:signal_out`, `:instruction_start`, `:instruction_end`, `:note`, `:error`, and `:checkpoint`.

The `refs` map links entries to other Jido primitives. Common keys include `signal_id`, `instruction_id`, `action`, `agent_id`, and `parent_thread_id`.

## Creating and appending

Create a thread with `Thread.new/1` and append entries with `Thread.append/2`. Both return new structs.

```elixir
alias Jido.Thread

thread = Thread.new(metadata: %{user_id: "u_abc123"})

thread = Thread.append(thread, %{
  kind: :message,
  payload: %{role: "user", content: "What is the order status?"}
})

thread = Thread.append(thread, [
  %{kind: :tool_call, payload: %{name: "lookup_order"}, refs: %{agent_id: "agent_1"}},
  %{kind: :tool_result, payload: %{status: "shipped", tracking: "1Z999"}}
])

Thread.entry_count(thread)
# => 3
Thread.last(thread).kind
# => :tool_result
```

You do not need to set `seq`, `at`, or `id` on entries. The `EntryNormalizer` assigns these automatically during append, using the current entry count as the base sequence number.

## Querying entries

Thread provides several functions for inspecting entries without manual traversal.

```elixir
Thread.entry_count(thread)
# => 3

Thread.last(thread)
# => %Entry{seq: 2, kind: :tool_result, ...}

Thread.get_entry(thread, 0)
# => %Entry{seq: 0, kind: :message, ...}

Thread.to_list(thread)
# => [%Entry{seq: 0, ...}, %Entry{seq: 1, ...}, %Entry{seq: 2, ...}]
```

### Filtering and slicing

Filter entries by kind to extract specific interaction types. Slice by sequence range to get a window of history.

```elixir
messages = Thread.filter_by_kind(thread, :message)
tool_entries = Thread.filter_by_kind(thread, [:tool_call, :tool_result])

recent = Thread.slice(thread, 1, 2)
# => entries with seq 1 and 2
```

## Provider agnosticism

Thread stores raw interaction data without any LLM-specific formatting. It knows nothing about roles, message formats, or provider APIs. LLM context is projected from a Thread, not stored in it.

The `jido_ai` package provides `Jido.AI.Thread`, which extends the core Thread with role-based messaging and projection to provider-specific formats. This separation means your interaction history remains portable across providers.

## Automatic tracking

When you run actions through `Jido.Agent.Strategy.Direct`, you can enable automatic thread tracking. The strategy appends `:instruction_start` and `:instruction_end` entries for each action execution.

```elixir
agent = MyApp.Agent.cmd(agent, MyApp.LookupOrder,
  strategy_opts: [thread?: true]
)
```

If a thread already exists in the agent state, tracking activates automatically without the `thread?` option. Each `:instruction_end` entry includes a status field indicating whether the action completed with `:ok` or `:error`.

## Storage adapters

`Jido.Thread.Store` defines a behaviour for persisting threads with four callbacks: `init/1`, `load/2`, `save/2`, and `append/3`.

```elixir
alias Jido.Thread
alias Jido.Thread.Store

{:ok, store} = Store.new()

thread = Thread.new(id: "thread_order_123")
{:ok, store} = Store.save(store, thread)

{:ok, store, loaded} = Store.load(store, "thread_order_123")
```

The built-in `Store.Adapters.InMemory` adapter stores threads in a plain map with no external processes. It auto-creates threads on append if they do not exist, making it useful for tests.

Store operations return updated store state to preserve purity. This design lets adapters work without external processes while still supporting stateful backends.

For durable persistence beyond in-memory storage, implement the `Jido.Thread.Store` behaviour with your preferred backend.

## Next steps

- [Actions](/docs/concepts/actions) - understand the units of work that threads record
- [Signals](/docs/concepts/signals) - learn about typed event envelopes referenced in thread entries
- [Strategy](/docs/concepts/strategy) - see how strategies orchestrate action execution with thread tracking
