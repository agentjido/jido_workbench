%{
  title: "Build Your First Workflow",
  description: "Learn to compose multiple actions into complex, reliable workflows using Jido Plans for sequential and parallel execution.",
  category: :docs,
  order: 13,
  prerequisites: ["docs/learn/first-llm-agent"],
  learning_outcomes: ["Compose multiple actions into a single command", "Use Plans to define execution order and dependencies", "Handle directive output from multi-step workflows"],
}
---
Real-world tasks are rarely a single step. A workflow might involve fetching data, processing it, and then notifying a user. Jido allows you to compose small, focused [Actions](/docs/concepts/actions) into complex workflows that are reliable and easy to understand.

### How to Use It

The process involves three main steps:

1.  **Define Actions**: Create individual Elixir modules that implement the `Jido.Action` behaviour, each responsible for one specific task.
2.  **Build a Plan**: Use the `Jido.Plan` module to arrange your actions in the desired execution order, either sequentially or in parallel.
3.  **Execute**: Send the plan to an agent using its `cmd/2` function. The agent runs the workflow and returns a single `Jido.Instruction` containing the combined results.

### A Complete Example

Here is a complete example of a two-step workflow where a report is generated only after data is fetched.

```elixir
defmodule FetchData do
  use Jido.Action
  def run(_), do: {:ok, [:log, "Fetched data successfully."]}
end

defmodule GenerateReport do
  use Jido.Action
  def run(_), do: {:ok, [:reply, "Report generated."]}
end

# In your application code or IEx session
alias Jido.Plan
plan = Plan.sequential([FetchData, GenerateReport])

# Assuming you have an agent started from a previous tutorial
{:ok, instruction} = MyAgent.cmd(agent_pid, plan)

# The instruction contains directives from both actions
# instruction.directives -> [
#   {:log, "Fetched data successfully."},
#   {:reply, "Report generated."}
# ]
```

### Why Compose Actions?

While you could put all your logic into a single, large action, breaking it down provides significant advantages. Small, single-purpose actions are easier to test, reuse, and reason about. By composing them in a `Jido.Plan`, you delegate the complexity of execution flow, state management, and error handling to the Jido runtime, resulting in more robust systems.

### Create Multiple Actions

Let's define a few actions for a server health check. We need to check connectivity and disk space, then generate a report.

First, an action to check connectivity. For this tutorial, it will simply log a message.

```elixir
defmodule CheckConnectivityAction do
  use Jido.Action

  def run(_args) do
    # In a real app, this would ping a server.
    {:ok, [:log, "Connectivity OK."]}
  end
end
```

Next, an action to check disk space.

```elixir
defmodule CheckDiskSpaceAction do
  use Jido.Action

  def run(_args) do
    # This would check disk usage.
    {:ok, [:log, "Disk space OK."]}
  end
end
```

Finally, an action to compile the results into a report.

```elixir
defmodule GenerateStatusReportAction do
  use Jido.Action

  def run(_args) do
    {:ok, [:reply, "Server status: All systems nominal."]}
  end
end
```

### Build a Plan

With our actions defined, we can use `Jido.Plan` to define the workflow. The connectivity and disk space checks can run at the same time, so we'll place them in a parallel step using `Jido.Plan.parallel/1`. The report generation must happen after both checks are complete, so it will follow in a sequential step using `Jido.Plan.sequential/1`.

`Jido.Plan` allows you to nest plans to create a Directed Acyclic Graph (DAG) of execution.

```elixir
alias Jido.Plan

# Define a plan where two actions run in parallel,
# followed by a final sequential action.
health_check_plan =
  Plan.sequential([
    Plan.parallel([
      CheckConnectivityAction,
      CheckDiskSpaceAction
    ]),
    GenerateStatusReportAction
  ])
```

This plan ensures that `GenerateStatusReportAction` only runs after both `CheckConnectivityAction` and `CheckDiskSpaceAction` have completed successfully.

### Execute the Workflow

To run this plan, you send it to an agent just like you would a single action. The agent's runtime understands how to interpret the plan and execute the actions in the correct order.

```elixir
# Assuming `agent_pid` is the PID of your running agent
{:ok, instruction} = MyAgent.cmd(agent_pid, health_check_plan)

IO.inspect(instruction)
```

### Handle Directives

When an agent executes a plan, it collects the [directives](/docs/concepts/directives) from every action that runs. The final `Jido.Instruction` returned by `cmd/2` contains a flat list of all directives emitted during the workflow, in the order they were executed.

After running the `health_check_plan`, the resulting `instruction` would look like this:

```elixir
%Jido.Instruction{
  directives: [
    {:log, "Connectivity OK."},
    {:log, "Disk space OK."},
    {:reply, "Server status: All systems nominal."}
  ]
  # ... other fields omitted
}
```

Notice that the directives from the parallel actions appear first, followed by the directive from the final sequential action. Your application can now process this complete list of outcomes from the entire workflow.

### Next Steps

Now that you can build multi-step workflows, you're ready to manage state within an agent.

*   **Concepts**: [Actions](/docs/concepts/actions), [Directives](/docs/concepts/directives)
*   **Previous Tutorial**: [Build Your First Agent](/docs/learn/first-agent)
*   **Next Tutorial**: [Build a Stateful Counter Agent](/docs/learn/counter-agent)

