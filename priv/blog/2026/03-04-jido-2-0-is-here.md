%{
title: "Jido 2.0 is now available",
author: "Mike Hostetler",
tags: ~w(jido elixir ai agent-framework release),
description: "After 18 months of building and rethinking, Jido 2.0 ships with a simpler BEAM-first agent core, production-ready AI strategies, and a growing ecosystem.",
post_type: :release,
audience: :general,
journey_stage: :operationalization,
content_intent: :reference,
capability_theme: :runtime_foundations,
evidence_surface: :package
}

---

After 18 months of building, rewriting, and rethinking, Jido 2.0 has shipped. It’s available on [Hex](https://hex.pm/packages/jido) now.

Jido started as a bot platform called BotHive in 2024. Then the AI wave hit and everything changed. I was already using Elixir and decided to make a bet: the BEAM is the best runtime for agent systems.

TypeScript agent frameworks felt like toys. Single-threaded event loops trying to juggle concurrent agents with promises and prayer. Python agents did a little better, but after a long time they couldn’t stay up. The BEAM was built for exactly this kind of work.

After working with agents on the BEAM for 18 months, that bet certainly looks to be paying off.

## From 1.0 to 2.0

Jido 1.0 was released last March, but admittedly was overengineered. I was still learning OTP in depth, and it showed. I added abstractions that didn’t make sense in practice. This created too much friction to do basic things that other agent frameworks made easy out of the box.

The feedback was clear and consistent. People wanted to build agents, not fight the framework. I took all of that feedback and addressed it in 2.0. Simpler APIs. Less ceremony. BEAM-first from the ground up.

Here’s what we shipped:

## A strong, durable agent core

The foundation of Jido 2.0 is a pure functional agent architecture. Agents are data. A struct with state, actions, and tools that can be run inside a GenServer. That’s it.

Everything flows through a single function: `cmd/2`. Actions go in. An updated agent and a list of directives come out. The agent is always just data. Side effects are described as directives, typed data structures that the runtime executes. This makes agents easier to reason about, test, and debug.

Here’s an example:

```elixir
defmodule MyAgent do
  use Jido.Agent,
    name: "my_agent",
    description: "A simple agent",
    strategy: Jido.Agent.Strategy.Direct,
    actions: [MyApp.Actions.ProcessOrder],
    schema: [
      order_count: [type: :integer, default: 0]
    ]
end

# Pure function - no processes, no side effects, fully testable
{:ok, updated_agent, directives} = Jido.Agent.cmd(agent, {ProcessOrder, order_id: "123"})
```

You can unit test every decision an agent makes without touching a network, a database, or an LLM.

Every feature in Jido is built around this basic concept.

`Jido.AgentServer` wraps any agent in a supervised `GenServer` with signal routing, directive execution, and parent-child agent hierarchies. It’s the agent runtime for everything that follows.

Strategies are the key extension point. They control how `cmd/2` processes actions, and they’re pluggable. Two ship with core Jido: `Direct` (sequential execution) and `FSM` (state machines with transition guards). These cover a lot of ground without any AI involvement at all.

This is also how Jido AI plugs in. The ReAct, Chain-of-Thought, and other reasoning strategies are just strategy implementations that add LLM calls to the loop. Same `cmd/2` contract, same directive system, same agent. The AI layer is an extension, not a separate world.

[jido_behaviortree](https://github.com/agentjido/jido_behaviortree) is another example. It adds behavior tree execution to Jido agents, no LLM required. Same strategy interface, completely different execution model.

In 2.0, we also split out actions and signals into their own focused packages:

[jido_action](https://github.com/agentjido/jido_action) is the universal action contract. Every capability an agent has is a `Jido.Action`, a composable, validated command with compile-time schema validation, lifecycle hooks, and automatic conversion to ReqLLM’s tool format for wide provider compatibility. It ships with 25+ pre-built tools and a DAG-based workflow planner for complex multi-step execution.

[jido_signal](https://github.com/agentjido/jido_signal) is the messaging nervous system. Built on the CloudEvents v1.0.2 spec, it provides standardized signal envelopes, a high-performance trie-based router, pub/sub bus, and nine dispatch adapters. Standards-based signals mean you can integrate with anything. Not a custom protocol, not a proprietary format.

## Jido AI

On top of the agent core sits [Jido AI](https://github.com/agentjido/jido_ai), a robust AI integration layer that turns raw LLM calls into structured agent intelligence.

Six reasoning strategies ship out of the box. ReAct is the most common and handles the majority of tool-calling use cases. Chain-of-Thought, Tree-of-Thoughts, Graph-of-Thoughts, TRM, and Adaptive are there for situations that need different tradeoffs between cost, depth, and quality.

```elixir
defmodule MyApp.SupportAgent do
  use Jido.AI.Agent,
    name: "support_agent",
    description: "Customer support agent with tool access",
    tools: [
      MyApp.Tools.LookupOrder,
      MyApp.Tools.CheckInventory,
      MyApp.Tools.CreateTicket
    ],
    model: "anthropic:claude-sonnet-4-20250514",
    max_iterations: 6,
    system_prompt: """
    You are a customer support agent. Use the available tools
    to look up orders, check inventory, and create tickets.
    Be concise and helpful.
    """
end

# Start the agent and ask a question
{:ok, pid} = Jido.AgentServer.start_link(agent: MyApp.SupportAgent)

{:ok, answer} = MyApp.SupportAgent.ask_sync(
  pid,
  "Order #4521 hasn't arrived. Can you check on it and open a ticket?",
  timeout: 60_000
)
```

The agent runs a ReAct loop: reason about the question, call tools, feed results back to the LLM, repeat until it has an answer. Tools are just `Jido.Action` modules, so anything you can define as an action becomes a tool the LLM can call.

Jido AI is built on [ReqLLM](https://github.com/agentjido/req_llm), my Elixir LLM client, which I had to build as a side quest because it didn’t exist. Streaming-first, multi-provider, with 11 provider implementations covering 665+ models. Sometimes the side quest turns into its own adventure. ReqLLM is now at version 1.6 with a growing community of contributors, and several companies running it in production.

## A growing ecosystem

Here’s where things get exciting. Jido isn’t just a framework anymore. It’s becoming an ecosystem.

A growing community of builders is using the BEAM to build agents. The momentum is real. People are building coding assistants, workflow orchestrators, research agents, and production support systems on top of Jido. And a growing set of packages is emerging to address other parts of the AI stack: browser automation, memory systems, evaluation harnesses, MCP integration. All built around the Jido core.

**First-class Ash Framework support**

[ash_jido](https://github.com/agentjido/ash_jido) shipped with 2.0. If you’re building on Ash, agents are now a first-class citizen. Add a `jido` DSL block to any Ash resource and your CRUD actions become AI-callable tools with authorization policies, data layers, and type safety preserved. And `ash_ai` is moving to ReqLLM as its LLM client, which means the two ecosystems are converging.

You can explore the full ecosystem at [jido.run/ecosystem](https://jido.run/ecosystem).

## Thank you

This release exists because of the Elixir community. The ecosystem we build on - Phoenix, LiveView, Ash, Req, Telemetry, NimbleOptions - is world-class. Every one of those libraries made Jido better by existing.

To the early testers and contributors who tried Jido when it was rough around the edges and gave honest, sometimes uncomfortable feedback: thank you. 2.0 is a direct result of that honesty. We’re grateful to be building here.

## Get building

```elixir
# mix.exs
def deps do
  [
    {:jido, "~> 2.0"},
    {:jido_ai, "~> 2.0"}
  ]
end
```

- Getting Started: [jido.run/docs/getting-started](https://jido.run/docs/getting-started)
- Docs: [hexdocs.pm/jido](https://hexdocs.pm/jido)
- Ecosystem: [jido.run/ecosystem](https://jido.run/ecosystem)
- GitHub: [github.com/agentjido](https://github.com/agentjido)
- Discord: [jido.run/discord](https://jido.run/discord)
