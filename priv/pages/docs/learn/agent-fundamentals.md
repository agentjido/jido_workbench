%{
  title: "Agent Fundamentals on the BEAM",
  description: "Learn the core Jido mental model: agents as data, actions as state transitions, and supervision-managed execution boundaries.",
  category: :docs,
  order: 20,
  prerequisites: ["/docs/learn/first-agent"],
  learning_outcomes: ["Explain why Jido models agents as data first", "Differentiate process lifecycle from agent state lifecycle", "Define a minimal agent schema and signal routing table"],
}
---
This guide establishes the fundamental mental model for building with Jido. If you've completed the [First Agent Tutorial](/docs/learn/first-agent), this is the next step to understand the design principles that make Jido agents reliable and predictable.

## What This Solves

In concurrent systems like Elixir, managing state is a primary challenge. A standard `GenServer` holds state, but the structure of that state and the logic for changing it are often implicit and mixed with side effects like database calls or sending messages. This makes testing difficult, reasoning about state transitions complex, and recovering from errors tricky.

Jido solves this by formalizing the agent's lifecycle into two distinct parts: a pure, data-centric core and a runtime that executes side effects. This separation provides:

*   **Testability:** Business logic can be tested without running processes.
*   **Predictability:** State transitions are deterministic and explicit.
*   **Reliability:** The blast radius of runtime errors is contained by OTP supervision, separate from the agent's logical state.

## How to Use It

The core workflow for defining and using a Jido agent involves these steps:

1.  **Define the Agent:** Create a module that `use Jido.Agent`.
2.  **Define the Schema:** Specify the agent's state structure, types, and default values using the `:schema` option.
3.  **Define Actions:** Create small, focused modules that contain the logic for a single state transition.
4.  **Define Signal Routes:** Map incoming events (signals) to the appropriate actions.
5.  **Run the Agent:** Start the agent within a `Jido.AgentServer` process, which handles message passing, state persistence, and side-effect execution.

## Examples

Before our main exercise, let's look at a minimal counter agent. This example shows the core components in action.

First, define the agent and its state schema:

```elixir
defmodule CounterAgent do
  use Jido.Agent,
    schema: [count: [type: :integer, default: 0]]
end
```

Next, define an action to modify the state. The `run/2` function takes the current agent state and parameters, and returns the new agent state and a list of directives (side effects).

```elixir
defmodule Actions.Increment do
  def run(agent, %{by: value}) when is_integer(value) and value > 0 do
    new_count = agent.state.count + value
    {:ok, agent} = Jido.Agent.set(agent, %{count: new_count})
    {agent, []} # Return the new agent and an empty list of directives
  end
end
```

With these modules, you can test the agent's logic purely, without any running processes:

```elixir
# Create an agent with default state
agent = CounterAgent.new()
# => %CounterAgent{state: %{count: 0}, ...}

# Execute the action
{new_agent, directives} = Jido.Agent.cmd(agent, {Actions.Increment, %{by: 5}})

new_agent.state.count
# => 5

directives
# => []
```

This demonstrates the core pattern: an action is a pure function that transforms an agent's state.

## References and Next Steps

This guide introduces the core concepts. To go deeper, see the following resources:

*   **Concepts:**
    *   [Agents](/docs/concepts/agents): The formal definition of the `Jido.Agent` data structure.
    *   [Agent Runtime](/docs/concepts/agent-runtime): Details on the `Jido.AgentServer` process model.
*   **Next Tutorial:**
    *   [Actions and Validation](/docs/learn/actions-validation): Learn how to build more robust actions with structured inputs and validation.

## Mental Model: Think vs. Act

The most important concept in Jido is the separation of state logic from runtime execution. We call this the "Think vs. Act" model, which is grounded in the two primary modules: `Jido.Agent` and `Jido.AgentServer`.

*   **Think (`Jido.Agent`):** This is the pure, functional core. A `Jido.Agent` is just an immutable data structure (a struct). All state transitions happen through the `Jido.Agent.cmd/2` function, which takes the current agent and an action, and returns a `{new_agent, directives}` tuple. This function is deterministic: given the same inputs, it will always produce the same outputs. It doesn't perform any side effects; it only *describes* them in the `directives` list.

*   **Act (`Jido.AgentServer`):** This is the runtime. It's a `GenServer` process that holds the agent's current state. It receives signals from the outside world, translates them into actions, and calls `Jido.Agent.cmd/2` to get the next state and directives. It then updates its internal state to be the `new_agent` and executes the side effects described by the `directives`. This is where database calls, API requests, and message passing happen.

This separation means you can develop and test the entire business logic of your agent (the "Think" part) without ever starting a process.

## State Schema

A Jido agent is a typed state container. You define its structure using the `:schema` option when you `use Jido.Agent`. The schema enforces consistency by defining field names, expected types, and default values.

```elixir
defmodule MyAgent do
  use Jido.Agent,
    schema: [
      status: [type: :atom, default: :idle],
      retries: [type: :integer, default: 0],
      last_error: [type: :string, default: nil]
    ]
end

agent = MyAgent.new()
# => %MyAgent{
#      state: %{
#        status: :idle,
#        retries: 0,
#        last_error: nil
#      },
#      ...
#    }
```

When you create a new agent, its state is automatically populated with the default values. When you update the state, Jido can validate the changes against the schema, ensuring data integrity.

## Signal Routing

An agent's internal actions are decoupled from the external world through signal routing. The `Jido.AgentServer` receives generic signals, which are typically simple atoms or tuples.

A routing table, usually defined in an agent's strategy, maps these signals to specific action modules. This allows you to change how an agent is triggered without altering its core business logic.

For example, a signal `:user_request` might be routed to an `Actions.ProcessRequest` module. This keeps the `AgentServer`'s interface simple and stable, while the agent's internal implementation can evolve.

## Deterministic Execution

The core of a Jido agent's reliability is the deterministic nature of `Jido.Agent.cmd/2`. It is a pure function. This has powerful implications:

*   **Testability:** You can write unit tests that assert the exact state transition for any given action, without mocks or complex setup.
*   **Debuggability:** If an agent ends up in an unexpected state, you can trace the sequence of actions that led to it. Since each step is deterministic, the bug is reproducible.
*   **Replayability:** You can record a stream of actions and replay them against an initial state to reconstruct the final state, which is useful for debugging and auditing.

Side effects, or `directives`, are returned as data. They are descriptions of what the runtime *should do*, not actions performed by the agent itself. This strict separation is what makes the execution predictable.

## Failure and Supervision

Jido leverages OTP to manage failure at two different levels:

1.  **Domain Failure:** This is a predictable failure in business logic. For example, trying to withdraw more money than is available in an account. This is not a crash. The action module handles this by returning an updated agent state (e.g., `status: :failed`) and/or an error directive. The process continues to run.

2.  **Runtime Failure:** This is an unexpected error, like a bug in code that causes the `AgentServer` process to crash. Because agents run as standard OTP processes, they are managed by a supervisor. The supervisor will restart the agent process according to its configured strategy, containing the failure and allowing the system to self-heal.

This two-level approach ensures that predictable business errors are handled gracefully within the agent's logic, while unpredictable system errors are handled by the fault-tolerant foundation of the BEAM.

## Hands-on Exercise: Inventory Agent

Let's build a simple agent to track product inventory. It will have a schema, two actions, and business logic to prevent selling out-of-stock items.

#### 1. Define the Agent Schema

Create a file `lib/inventory_agent.ex`:

```elixir
defmodule InventoryAgent do
  use Jido.Agent,
    schema: [
      sku: [type: :string],
      quantity_on_hand: [type: :integer, default: 0],
      status: [type: :atom, default: :active]
    ]
end
```

#### 2. Define the Actions

Create a file `lib/inventory_actions.ex` for the action modules.

```elixir
defmodule InventoryActions do
  defmodule AddStock do
    def run(agent, %{quantity: q}) when is_integer(q) and q > 0 do
      new_qty = agent.state.quantity_on_hand + q
      {:ok, agent} = Jido.Agent.set(agent, %{quantity_on_hand: new_qty})
      {agent, []}
    end
  end

  defmodule SellItem do
    def run(agent, %{quantity: q}) when is_integer(q) and q > 0 do
      current_qty = agent.state.quantity_on_hand

      if current_qty >= q do
        new_qty = current_qty - q
        {:ok, agent} = Jido.Agent.set(agent, %{quantity_on_hand: new_qty})
        {agent, []}
      else
        # Not enough stock. Change state and return an error directive.
        {:ok, agent} = Jido.Agent.set(agent, %{status: :out_of_stock})
        error = Jido.Error.new(:validation, "Insufficient stock")
        {agent, [%Jido.Agent.Directive.Error{error: error}]}
      end
    end
  end
end
```

#### 3. Test the Logic

Now, you can test the entire lifecycle in an `iex` session without starting any servers.

```elixir
# 1. Create a new agent for a specific SKU
agent = InventoryAgent.new(state: %{sku: "widget-123"})
# => %InventoryAgent{state: %{sku: "widget-123", quantity_on_hand: 0, ...}}

# 2. Add stock
{agent, _} = Jido.Agent.cmd(agent, {InventoryActions.AddStock, %{quantity: 10}})
agent.state.quantity_on_hand
# => 10

# 3. Sell an item successfully
{agent, _} = Jido.Agent.cmd(agent, {InventoryActions.SellItem, %{quantity: 3}})
agent.state.quantity_on_hand
# => 7

# 4. Attempt to sell more than is available
{agent, directives} = Jido.Agent.cmd(agent, {InventoryActions.SellItem, %{quantity: 10}})

# The state reflects the failure
agent.state.status
# => :out_of_stock
agent.state.quantity_on_hand
# => 7 (state was not changed)

# An error directive was returned for the runtime to handle
directives
# => [%Jido.Agent.Directive.Error{...}]
```

This exercise demonstrates the core principles: a typed schema provides structure, and pure actions create predictable, testable state transitions. The `SellItem` action shows how to handle a domain-specific rule (inventory checks), which is the focus of our next guide on [Actions and Validation](/docs/learn/actions-validation).

