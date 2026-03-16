defmodule AgentJido.Demos.TaskExecution.AddTasks do
  @moduledoc false

  use Jido.Action,
    name: "tasklist_add_tasks",
    description: "Adds tasks to the local deterministic task list demo",
    schema: [
      tasks: [type: {:list, :map}, required: true]
    ]

  @impl true
  def run(%{tasks: tasks}, _context) when is_list(tasks) do
    created_tasks =
      tasks
      |> Enum.with_index(1)
      |> Enum.map(fn {task, index} ->
        task
        |> stringify_keys()
        |> Map.put_new("id", "task-#{index}")
        |> Map.put("status", "pending")
        |> Map.put_new("result", nil)
        |> Map.put_new("blocked_reason", nil)
      end)

    {:ok,
     %{
       created_tasks: created_tasks,
       message: "Added #{length(created_tasks)} task(s) to the list."
     }}
  end

  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} -> {key, value}
    end)
  end
end

defmodule AgentJido.Demos.TaskExecution.StartTask do
  @moduledoc false

  use Jido.Action,
    name: "tasklist_start_task",
    description: "Marks a task as in progress in the local deterministic task list demo",
    schema: [
      task_id: [type: :string, required: true]
    ]

  @impl true
  def run(%{task_id: task_id}, context) do
    tasks = Map.get(context, :tasks, [])

    case Enum.find(tasks, &(&1["id"] == task_id)) do
      nil ->
        {:error, :task_not_found}

      task ->
        {:ok,
         %{
           task: Map.put(task, "status", "in_progress"),
           message: "Started task: #{task["title"]}"
         }}
    end
  end
end

defmodule AgentJido.Demos.TaskExecution.CompleteTask do
  @moduledoc false

  use Jido.Action,
    name: "tasklist_complete_task",
    description: "Marks a task as complete in the local deterministic task list demo",
    schema: [
      task_id: [type: :string, required: true],
      result: [type: :string, required: true]
    ]

  @impl true
  def run(%{task_id: task_id, result: result}, context) do
    tasks = Map.get(context, :tasks, [])

    case Enum.find(tasks, &(&1["id"] == task_id)) do
      nil ->
        {:error, :task_not_found}

      task ->
        {:ok,
         %{
           task:
             task
             |> Map.put("status", "done")
             |> Map.put("result", result),
           message: "Completed task: #{task["title"]}"
         }}
    end
  end
end

defmodule AgentJido.Demos.TaskExecution.GetState do
  @moduledoc false

  use Jido.Action,
    name: "tasklist_get_state",
    description: "Returns the current task list state for the local deterministic task list demo",
    schema: []

  @impl true
  def run(_params, context) do
    tasks = Map.get(context, :tasks, [])

    summary = %{
      total: length(tasks),
      pending: count_status(tasks, "pending"),
      in_progress: count_status(tasks, "in_progress"),
      done: count_status(tasks, "done"),
      blocked: count_status(tasks, "blocked")
    }

    {:ok,
     %{
       tasks: tasks,
       summary: summary,
       all_complete: summary.total > 0 and summary.done == summary.total
     }}
  end

  defp count_status(tasks, status) do
    Enum.count(tasks, &(&1["status"] == status))
  end
end

defmodule AgentJido.Demos.TaskExecution.NextTask do
  @moduledoc false

  use Jido.Action,
    name: "tasklist_next_task",
    description: "Returns the next task to work on for the local deterministic task list demo",
    schema: []

  @impl true
  def run(_params, context) do
    tasks = Map.get(context, :tasks, [])
    in_progress = Enum.filter(tasks, &(&1["status"] == "in_progress"))

    cond do
      tasks == [] ->
        {:ok, %{status: "no_tasks", message: "No tasks in the list. Add tasks first."}}

      in_progress != [] ->
        {:ok,
         %{
           status: "tasks_in_progress",
           in_progress: in_progress,
           message: "#{length(in_progress)} task(s) are already in progress."
         }}

      pending = Enum.find(tasks, &(&1["status"] == "pending")) ->
        {:ok,
         %{
           status: "next_task",
           task: pending,
           message: "Next task ready: #{pending["title"]}."
         }}

      Enum.all?(tasks, &(&1["status"] == "done")) ->
        {:ok, %{status: "all_complete", message: "All tasks are complete."}}

      true ->
        {:ok, %{status: "no_tasks", message: "No task is available to start."}}
    end
  end
end
