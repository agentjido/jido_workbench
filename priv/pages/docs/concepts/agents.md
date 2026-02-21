%{
  title: "Agents",
  description: "Modeling agent state, lifecycle, and command handling.",
  category: :docs,
  legacy_paths: ["/docs/agents"],
  order: 70,
  in_menu: true,
  draft: false,
}
---
Managing state and side effects in complex, multi-step workflows is notoriously difficult. When building systems that coordinate multiple tasks—especially those involving external APIs, LLMs, or asynchronous events—state mutations often become entangled with side effects. This entanglement leads to race conditions, untestable code, and cascading failures in production.

Jido solves this by treating agent state as a purely functional, immutable data structure. Instead of allowing arbitrary state mutations scattered across your codebase, Jido forces all state changes through a strict command boundary. Actions return updated state and a list of declarative effects (directives). This separation of concerns means you can test complex agent logic without mocking external services, and you can rely on the Erlang VM (OTP) to handle the actual execution of side effects safely.

## When to Use It

You should use Jido Agents when you are building systems that require predictable state transitions over time. If your workflow involves a single, synchronous API call, a simple function is sufficient. However, you need an Agent when:

- You are orchestrating multi-step workflows where the output of one step determines the next.
- You need to maintain long-lived state that must be validated against a strict schema.
- You require an audit trail of exactly how and why state changed.
- You are building multi-agent systems where components must communicate asynchronously via structured signals.
- You need to isolate failures so that a crash in one workflow step does not bring down the entire application.

If you need rapid prototyping at the expense of runtime safety, other tools might be faster. If you need reliable, long-term operation in production, Jido Agents provide the necessary architectural rigor.

## Definition and Mental Model

In Jido, an Agent is an immutable data structure that holds state and is updated exclusively via commands. 

The mental model is a purely functional core wrapped in an operational shell. You do not "tell the agent to do something" and wait for it to mutate itself. Instead, you pass the current agent state and an action to the `Jido.Agent.cmd/2` function. 

This function evaluates the action against the state and returns a tuple: `{updated_agent, directives}`. 

- **`updated_agent`**: A completely new copy of the agent struct with the state modified according to the action. It is always complete and valid.
- **`directives`**: A list of declarative structs (like `%Jido.Agent.Directive.Emit{}`) that describe side effects the runtime should perform. 

The agent itself never executes the directives. It only produces them. The surrounding runtime (typically a Jido Agent Server) is responsible for interpreting those directives and interacting with the outside world.

## Quick Start

To define an agent, you use the `Jido.Agent` module and provide a schema for its state. Here is a minimal, runnable example of defining an agent and executing a command.

```elixir
defmodule MyApp.WorkerAgent do
  use Jido.Agent,
    name: "worker_agent",
    description: "A basic worker agent",
    schema: [
      status: [type: :atom, default: :idle],
      tasks_completed: [type: :integer, default: 0]
    ]
end

# 1. Create a new, fully initialized agent
agent = MyApp.WorkerAgent.new()

# 2. Define a simple action (normally in its own module)
defmodule MyApp.CompleteTaskAction do
  use Jido.Action, name: "complete_task"
  
  def run(%{agent: agent}, _params) do
    new_state = %{
      status: :active,
      tasks_completed: agent.state.tasks_completed + 1
    }
    {:ok, new_state}
  end
end

# 3. Execute the command
{updated_agent, directives} = MyApp.WorkerAgent.cmd(agent, MyApp.CompleteTaskAction)

IO.inspect(updated_agent.state.tasks_completed) # => 1
IO.inspect(directives) # => []
```

## How It Works

The Jido Agent architecture is divided into three distinct responsibilities, handled by three core modules. Understanding this separation is critical for building reliable systems.

### 1. `Jido.Agent` (The Data Structure)
This is the public API and the immutable struct itself. When you call `Jido.Agent.new/1`, it generates the struct based on your schema. It exposes the primary `cmd/2` function, which acts as the entry point for all state transitions. It is responsible for ensuring that the state always conforms to the defined schema via `Jido.Agent.validate/2`.

### 2. `Jido.Agent.Cmd` (The Pipeline)
When you call `Jido.Agent.cmd/2`, the request is routed through `Jido.Agent.Cmd`. This module is the internal pipeline. It normalizes the input (whether you passed a single action module, a tuple with parameters, or a list of actions), resolves the execution strategy, and orchestrates the application of actions to the state. It accumulates any directives produced during this process and ensures the final `{agent, directives}` tuple is correctly formatted.

### 3. `Jido.Agent.Strategy` (The Execution Behavior)
While `Jido.Agent.Cmd` handles the pipeline, `Jido.Agent.Strategy` dictates *how* actions are executed. The strategy defines the execution flow. By default, Jido uses `Jido.Agent.Strategy.Direct`, which executes actions immediately and sequentially. However, the strategy behaviour (`Jido.Agent.Strategy.cmd/3`) allows for advanced execution models, such as multi-step behavior trees or LLM-driven planning loops, without changing the core agent data structure.

## Progressive Examples

Let's move from the minimal setup to a realistic production scenario. In this example, we define an agent that processes user registrations, updates its internal state, and explicitly emits a signal to the rest of the system.

```elixir
defmodule MyApp.RegistrationAgent do
  use Jido.Agent,
    name: "registration_agent",
    schema: [
      users_processed: [type: :integer, default: 0],
      last_user_id: [type: :string, required: false]
    ]
end

defmodule MyApp.ProcessUserAction do
  use Jido.Action, 
    name: "process_user",
    schema: [user_id: [type: :string, required: true]]

  def run(%{agent: agent}, %{user_id: user_id}) do
    # 1. Update the agent's state
    new_state = %{
      users_processed: agent.state.users_processed + 1,
      last_user_id: user_id
    }

    # 2. Produce a directive to emit a signal
    signal = %Jido.Signal{
      type: "user.processed",
      source: "/agent/registration",
      data: %{user_id: user_id}
    }
    
    directive = %Jido.Agent.Directive.Emit{signal: signal}

    # Return the state update and the directive
    {:ok, new_state, directive}
  end
end

# Execution
agent = MyApp.RegistrationAgent.new()

# Pass the action and its parameters as a tuple
{updated_agent, directives} = 
  MyApp.RegistrationAgent.cmd(agent, {MyApp.ProcessUserAction, %{user_id: "usr_123"}})

# The agent state is updated immediately
assert updated_agent.state.users_processed == 1
assert updated_agent.state.last_user_id == "usr_123"

# The directive is returned for the runtime to handle
assert [%Jido.Agent.Directive.Emit{}] = directives
```

In a production environment, this `{updated_agent, directives}` tuple is returned to the Jido Agent Server, which then safely executes the `Emit` directive using OTP concurrency primitives.

## Failure Modes and Operational Boundaries

Jido Agents are designed to fail safely and predictably. Because the core is purely functional, failures during `cmd/2` do not leave the agent in a corrupted state. 

If an action fails, or if the resulting state fails `Jido.Agent.validate/2`, the `cmd/2` function will return an error tuple (or raise, depending on the invocation method). The original agent state remains untouched. 

Operationally, this means you can wrap agent execution in standard OTP supervision trees. If an agent process encounters an unrecoverable error, the supervisor restarts it from its last known good state. Directives provide a clear operational boundary: because side effects (like network calls) are deferred to the runtime via directives, a network timeout does not corrupt the agent's internal state memory. 

For a complete guide on running agents safely, review the [Production Readiness Checklist](/docs/operations/production-readiness-checklist).

## Reference and Next Steps

To deepen your understanding of the Jido ecosystem and how agents interact with other primitives, explore the following resources:

- **Core Primitives:** Learn how agents use [Actions](/docs/concepts/actions) to perform work and [Signals](/docs/concepts/signals) to communicate.
- **Effect Management:** Understand how [Directives](/docs/concepts/directives) safely bridge the functional core and the imperative shell.
- **Implementation:** Review the [Jido Package Reference](/docs/reference/packages/jido) and the general [Reference Hub](/docs/reference).
- **Operations:** Read the [Operations Guide](/docs/operations) for telemetry and debugging.
- **Practical Application:** Start building with the [Build Hub](/build).

## What an Agent Is (and Is Not)

To operate Jido effectively, you must adopt its specific definition of an Agent.

**What an Agent Is:**
An Agent in Jido is a strictly typed, immutable data structure that encapsulates state and a set of allowed operations. It enforces a schema, validates state transitions, and separates the calculation of state changes from the execution of side effects. It is a predictable, testable unit of logic.

**What an Agent Is Not:**
An Agent is not a GenServer. While Jido provides an `AgentServer` to run agents in long-lived processes, the Agent itself is just the data structure inside that server. 

Furthermore, a Jido Agent is not a magical, unbounded AI loop. It is not a generic wrapper around an LLM prompt. While you can use LLMs within Jido Actions to drive agent behavior, the Agent itself remains a deterministic state machine. Jido rejects the paradigm of "black box" autonomous agents in favor of engineered, observable coordination.

## Agent Lifecycle and Command Boundary

The lifecycle of an agent revolves entirely around the command boundary enforced by `Jido.Agent.cmd/2`. 

When an agent is instantiated via `Jido.Agent.new/1`, it is initialized with its default schema values and an empty strategy state. From that point forward, the only way to evolve the agent is by passing it to `cmd/2` along with an action.

### `cmd/2` Return Semantics
The return signature of `cmd/2` is the most important concept in Jido:

`{agent, directives}`

1.  **The Agent is Always Complete:** The `agent` returned in the tuple has already had all state transformations applied. There is no secondary "apply directives to state" step. If an action increments a counter, the returned agent has the incremented counter.
2.  **Directives are Produced, Not Consumed:** Directives are strictly outbound instructions. They are generated by actions during the `cmd/2` evaluation. For example, if an action determines that a child process needs to be spawned, it returns a `%Jido.Agent.Directive.Spawn{}` struct. The `cmd/2` pipeline collects these structs and returns them in the list. The agent never receives directives as input; it only emits them for the runtime to execute.

This strict boundary ensures that testing an agent requires no mocks. You simply pass in a state and an action, and assert on the returned state and the list of declarative directives.

## API Surface Map

The API surface for defining and interacting with agents is intentionally minimal to enforce the functional core pattern.

### Key Modules

| Module | Purpose |
|--------|---------|
| `Jido.Agent` | The core immutable struct, schema definition, and public API. |
| `Jido.Agent.Cmd` | The internal pipeline that normalizes actions and accumulates directives. |
| `Jido.Agent.Strategy` | The behaviour defining how actions are executed (e.g., sequentially vs. multi-step). |

### Strategy Selection Guidance

| Strategy | Best For | Execution Profile |
|---|---|---|
| `Jido.Agent.Strategy.Direct` | Standard workflows, deterministic state machines. | Immediate, sequential execution of actions. (Default) |
| `Custom (e.g., BehaviorTree)` | Complex decision logic, game AI, multi-step planning. | Tick-based evaluation, stateful execution tracking. |

### Key Functions

| Function | Description |
|----------|-------------|
| `Jido.Agent.new/1` | Creates a new agent struct, initializing state according to the defined schema. |
| `Jido.Agent.cmd/2` | The primary command boundary. Evaluates an action against the agent, returning `{updated_agent, directives}`. |
| `Jido.Agent.validate/2` | Validates the current agent state against its schema, returning `{:ok, agent}` or an error. |
| `Jido.Agent.Strategy.cmd/3` | The callback implemented by strategies to define custom execution logic. |

## Source Files
- `lib/jido/agent.ex`
- `lib/jido/agent/cmd.ex`
- `lib/jido/agent/strategy.ex`

