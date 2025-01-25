defmodule JidoWorkbench.Jido.BasicTaskAgent do
  use Jido.Agent,
    name: "BasicTaskAgent",
    description: "Basic Task management agent for maintaining todo lists",
    actions: [
      JidoWorkbench.Actions.AddTask,
      JidoWorkbench.Actions.CompleteTask,
      JidoWorkbench.Actions.ListTasks,
      JidoWorkbench.Actions.UpdateTask
    ],
    runner: Jido.Runner.Simple,
    schema: [
      tasks: [type: {:list, :map}, required: true, doc: "List of tasks"]
    ]

  alias __MODULE__
  alias JidoWorkbench.Actions.{AddTask, ListTasks, UpdateTask, CompleteTask}
  require Logger

  def add_task(agent, params) do
    cmd(agent, {AddTask, params}, %{}, context: %{state: agent.state})
  end

  def list_tasks(agent, params) do
    cmd(agent, {ListTasks, params}, %{}, context: %{state: agent.state})
  end

  def update_task(agent, params) do
    cmd(agent, {UpdateTask, params}, %{}, context: %{state: agent.state})
  end

  def complete_task(agent, params) do
    cmd(agent, {CompleteTask, params}, %{}, context: %{state: agent.state})
  end
end
