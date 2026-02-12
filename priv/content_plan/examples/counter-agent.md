%{
  title: "Counter Agent Example",
  order: 1,
  purpose: "Demonstrate the foundational Jido pattern: immutable agent, validated actions, signal routing, and LiveView integration",
  audience: :beginner,
  content_type: :tutorial,
  learning_outcomes: [
    "Define a Jido Agent with a typed schema",
    "Write Actions with validated parameters",
    "Wire signal routes to actions",
    "Drive a Phoenix LiveView from agent state via cmd/2"
  ],
  repos: ["jido"],
  source_modules: [
    "Jido.Agent",
    "Jido.Action",
    "AgentJido.Demos.CounterAgent",
    "AgentJido.Demos.Counter.IncrementAction",
    "AgentJido.Demos.Counter.DecrementAction",
    "AgentJido.Demos.Counter.ResetAction"
  ],
  source_files: [
    "lib/agent_jido/demos/counter/counter_agent.ex",
    "lib/agent_jido/demos/counter/actions/increment_action.ex",
    "lib/agent_jido/demos/counter/actions/decrement_action.ex",
    "lib/agent_jido/demos/counter/actions/reset_action.ex",
    "lib/agent_jido_web/examples/counter_agent_live.ex"
  ],
  status: :published,
  priority: :critical,
  prerequisites: [],
  related: ["first-agent", "actions", "signals"],
  ecosystem_packages: ["jido"],
  tags: [:examples, :getting_started, :agents, :actions, :signals]
}
---
## Content Brief

The canonical beginner example for the Jido Workbench. A simple counter agent
that demonstrates all foundational concepts in one interactive page:

1. **Agent definition** — `CounterAgent` with `use Jido.Agent`, schema `[count: [type: :integer, default: 0]]`
2. **Actions** — Three action modules (`IncrementAction`, `DecrementAction`, `ResetAction`) each with `use Jido.Action`, validated params, and `run/2`
3. **Signal routing** — `signal_routes/1` maps signal types to action modules
4. **LiveView integration** — `CounterAgentLive` creates the agent, dispatches actions via `cmd/2`, and renders state reactively

### Implementation Status

- ✅ Agent module: `lib/agent_jido/demos/counter/counter_agent.ex`
- ✅ Action modules: `lib/agent_jido/demos/counter/actions/`
- ✅ LiveView demo: `lib/agent_jido_web/examples/counter_agent_live.ex`
- ✅ NimblePublisher entry: `priv/examples/counter-agent.md`
- ✅ Syntax-highlighted source code viewer (compile-time Makeup)
- ✅ URL-driven tabs (demo / explanation / source)

### Validation Criteria

- All code compiles against jido 2.0.0-rc.4+
- `cmd/2` contract matches current `Jido.Agent` API
- `signal_routes/1` callback signature is correct (takes `_ctx` arg)
- Agent is purely functional — no GenServer, no PID
- LiveView uses `live_render/3` for embedding as a child
