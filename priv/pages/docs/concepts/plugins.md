%{
  title: "Plugins",
  description: "Composable capability bundles that extend agents with actions, routes, and state.",
  category: :docs,
  order: 105,
  tags: [:docs, :concepts],
  legacy_paths: ["/docs/plugins"],
  draft: false
}
---

A Plugin is a composable capability that you attach to an agent. It bundles actions, state, signal routing, and lifecycle hooks into a single reusable module. Plugins let you build agent capabilities once and share them across any number of agents.

## What plugins solve

Without plugins, every agent must define its own actions, signal routes, and state fields inline. This works for simple agents but breaks down when multiple agents need the same capability. You end up duplicating action lists, route tables, and initialization logic across modules.

Plugins solve this by packaging a complete capability into one module. A chat plugin brings its own actions, message history state, and signal routes. A database plugin brings connection pooling, query actions, and health checks. You declare the plugins you want and the agent gains those capabilities at compile time.

Plugins also enforce structure. Each plugin validates its configuration at compile time using Zoi schemas, declares its dependencies explicitly, and isolates its state under a dedicated key. This prevents plugins from stepping on each other or corrupting shared state.

## Anatomy of a plugin

You define a plugin with `use Jido.Plugin` and a set of required options:

```elixir
defmodule MyApp.ChatPlugin do
  use Jido.Plugin,
    name: "chat",
    state_key: :chat,
    actions: [MyApp.Actions.SendMessage, MyApp.Actions.ListHistory],
    schema: Zoi.object(%{
      messages: Zoi.list(Zoi.any()) |> Zoi.default([]),
      model: Zoi.string() |> Zoi.default("gpt-4")
    }),
    signal_patterns: ["chat.*"],
    signal_routes: [
      {"chat.send", MyApp.Actions.SendMessage},
      {"chat.history", MyApp.Actions.ListHistory}
    ]
end
```

Three options are required. `name` identifies the plugin. `state_key` is the atom key under which the plugin's state lives in the agent struct. `actions` lists the action modules the plugin provides.

The optional `schema` defines the shape and defaults for the plugin's state slice using a Zoi schema. `config_schema` defines a separate schema for per-agent configuration, letting each agent customize the plugin at declaration time. Both schemas are validated at compile time.

## Plugin lifecycle

Plugins follow a five-stage lifecycle from compile time through runtime signal processing.

**Compile time.** You declare plugins in the agent's `plugins:` option. Jido validates each plugin's configuration against its schemas and merges the plugin's actions and routes into the agent's definitions.

```elixir
defmodule MyAgent do
  use Jido.Agent,
    name: "my_agent",
    plugins: [
      MyApp.ChatPlugin,
      {MyApp.DatabasePlugin, %{pool_size: 5}}
    ]
end
```

You can pass a plugin module directly or as a tuple with a configuration map. The configuration map is validated against the plugin's `config_schema`.

**Mount.** When you call `Agent.new/1`, each plugin's `mount/2` callback runs to initialize plugin-specific state. This is a pure function with no side effects. It receives the agent struct and the per-agent config, and returns a map that gets merged into the plugin's state slice.

```elixir
@impl Jido.Plugin
def mount(agent, config) do
  {:ok, %{initialized_at: DateTime.utc_now()}}
end
```

**Child processes.** When `AgentServer.init/1` runs, it calls each plugin's `child_spec/1` callback. Returned process specifications are started and monitored by the agent server. If a plugin needs a worker process, connection pool, or background task, this is where it declares them.

**Signal handling.** During signal processing, each plugin's `handle_signal/2` callback runs before the signal reaches the router. Plugins execute in declaration order. This hook can inspect, transform, or override the signal's routing.

**Result transformation.** On the synchronous call path, `transform_result/3` runs after action execution. It lets a plugin modify the agent struct returned to the caller without affecting internal server state.

## Signal routing

Plugins contribute signal routes to the agent's unified router. You declare routes in two ways.

Static routes use the `signal_routes:` compile-time option. Each tuple maps a signal type string to an action module:

```elixir
use Jido.Plugin,
  signal_routes: [
    {"chat.send", MyApp.Actions.SendMessage},
    {"chat.history", MyApp.Actions.ListHistory}
  ]
```

For dynamic routes that depend on runtime configuration, override the `signal_routes/1` callback instead. Static routes are preferred when the mapping is known at compile time.

The `signal_patterns` option controls which signals reach the plugin's `handle_signal/2` hook. Patterns use dot-delimited wildcards like `"chat.*"`. A plugin with an empty patterns list acts as global middleware and receives all signals.

The `handle_signal/2` callback returns one of several responses:

- `{:ok, :continue}` to pass through to normal routing
- `{:ok, {:continue, signal}}` to rewrite the signal before routing
- `{:ok, {:override, action}}` to bypass the router entirely
- `{:error, reason}` to abort signal processing

## Requirements and capabilities

Plugins declare what they need and what they provide using `requires` and `capabilities`.

The `requires` option lists dependencies as tagged tuples. Three dependency types are supported:

- `{:config, :api_key}` requires a configuration value
- `{:app, :req}` requires an OTP application to be available
- `{:plugin, :http}` requires another plugin's capability

The `capabilities` option lists atoms that describe what the plugin provides. Other plugins can depend on these capabilities through the `{:plugin, :capability}` requirement. This creates a declarative dependency graph that Jido validates at compile time.

```elixir
use Jido.Plugin,
  name: "slack_notifier",
  state_key: :slack,
  actions: [MyApp.Actions.NotifySlack],
  capabilities: [:notifications],
  requires: [
    {:config, :slack_token},
    {:plugin, :http}
  ]
```

Plugins can also declare `schedules` for cron-style periodic execution. Each schedule is a tuple of a cron expression and an action module:

```elixir
schedules: [{"*/5 * * * *", MyApp.Actions.SyncMessages}]
```

## Next steps

- Read about [Actions](/docs/concepts/actions) to understand the building blocks that plugins bundle together
- Learn how [Signals](/docs/concepts/signals) flow through the routing system that plugins extend
- See [Agent runtime](/docs/concepts/agent-runtime) for how child processes and signal dispatch work at the server level
