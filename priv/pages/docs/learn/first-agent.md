%{
  title: "Build Your First Agent (no LLM)",
  description: "A step-by-step tutorial for building your first deterministic agent in Jido, focusing on state management with `cmd/2` and actions.",
  category: :docs,
  order: 11,
}
---
This guide walks you through building your first Jido agent, focusing on deterministic state management without any Large Language Models (LLMs). You will define an agent, create an action to modify its state, and execute it to see how Jido separates state changes from side effects.

### What This Solves

Jido provides a reliable way to manage state and side effects in complex workflows. Instead of mutating state directly and triggering side effects from anywhere in your code, Jido agents use a pure function, `cmd/2`, to process actions. This ensures that for the same agent state and action, you always get the same new state and the same description of side effects, making your system predictable and easy to test.

### How to Use It

The core workflow for a deterministic agent is straightforward and predictable. You will define your agent's structure, create actions that can change it, and then execute those actions to produce a new state and a list of requested side effects (called directives).

1.  **Define an Agent:** Create a module with `use Jido.Agent` and specify a schema for its state.
2.  **Define Actions:** Create modules with `use Jido.Action` that implement an `execute/2` function to transform the agent's state.
3.  **Execute Commands:** Use the agent's `cmd/2` function to apply an action, receiving an updated agent and a list of directives.

This separation makes your agent's logic pure and testable, while the runtime handles the messy parts of executing side effects.

### Define Your Agent

First, you need to define the agent and the shape of its state. An agent is an Elixir module that uses `Jido.Agent` and defines a `schema` for its internal data. This schema provides type validation and default values.

Let's create a simple `CounterAgent` that just holds a single integer.

```elixir
defmodule CounterAgent do
  use Jido.Agent,
    name: "counter_agent",
    description: "A simple agent that counts.",
    schema: [
      count: [type: :integer, default: 0]
    ]
end
```

By using `Jido.Agent`, this module automatically gets functions like `new/1` to create an agent instance and `cmd/2` to execute actions against it. The state will always conform to the schema you defined.

### Create an Action

Next, define an action to interact with the agent. Actions are Elixir modules that use `Jido.Action`. They implement `run/2`, where the first argument is validated action params and the second argument is execution context (including `context.state`).

Here is an `IncrementBy` action that adds a specific amount to the counter.

```elixir
defmodule IncrementBy do
  use Jido.Action,
    name: "increment_by",
    schema: [
      amount: [type: :integer, default: 1]
    ]

  @impl true
  def run(%{amount: amount}, %{state: state}) do
    current = Map.get(state, :count, 0)
    {:ok, %{count: current + amount}}
  end
end
```

This action defines a parameter schema for `:amount`, reads current state from `context.state`, and returns a result map. `cmd/2` merges that map into agent state and returns any directives separately.

### Execute with `cmd/2`

Now you can use these pieces together to manage state transitions. The `cmd/2` function is the heart of a Jido agent; it takes the current agent and an action, then returns the new agent and any directives produced by the action.

Let's see it in an `iex` session.

```elixir
# 1. Create a new agent instance. Its count is the default of 0.
agent = CounterAgent.new()
#=> %CounterAgent{state: %{count: 0}, ...}

# 2. Execute the IncrementBy action with an amount of 5.
{new_agent, directives} = CounterAgent.cmd(agent, {IncrementBy, %{amount: 5}})
```

After running the command, `new_agent` will contain the updated state, and `directives` will hold any requested side effects. This function is pure; it has no side effects itself.

### Understand the Output

The return value of `cmd/2` is a tuple containing the new agent state and a list of directives. This separation is a core principle of Jido.

Let's inspect the results from the previous step:

```elixir
# The new agent has the updated count.
new_agent
#=> %CounterAgent{state: %{count: 5}, ...}

# The directives list is empty because our action didn't request side effects.
directives
#=> []
```

-   **The New Agent:** `new_agent` is a completely new struct with the updated state. The original `agent` variable is unchanged, preserving immutability.
-   **Directives:** The `directives` list contains instructions for the Jido runtime. If our action needed to log a message, emit an event, or start another process, it would have returned a directive struct in this list. Because our counter is purely deterministic, the list is empty.

This model ensures that your core logic remains simple and testable, while the runtime is responsible for interpreting and executing the side effects described by directives.

### References and Next Steps

You've successfully built a deterministic agent. This pattern is the foundation for all other agent-based systems in Jido.

-   To see a more complete version of this example, check out the [Counter Agent Example](/docs/learn/counter-agent).
-   To learn how to integrate LLMs, see [Build Your First LLM Agent](/docs/learn/first-llm-agent).
-   For a deeper dive into the concepts, read about [Agents](/docs/concepts/agents) and [Actions](/docs/concepts/actions).
