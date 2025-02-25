defmodule JidoWorkbench.Actions.AddTask do
  require Logger

  use Jido.Action,
    name: "add_task",
    description: "Add a new task to the todo list",
    schema: [
      title: [type: :string, required: true, doc: "Title of the task"],
      description: [type: :string, required: false, doc: "Optional description"],
      priority: [
        type: :string,
        required: false,
        doc: "Priority level (low, medium, high)",
        default: "medium"
      ],
      due_date: [type: :string, required: false, doc: "Due date in ISO8601 format"]
    ]

  def run(params, context) do
    Logger.metadata(action: "add_task")

    # Create new task
    task = %{
      id: Jido.Util.generate_id(),
      title: params.title,
      description: params.description,
      status: :pending,
      priority: safe_parse_priority(params.priority),
      due_date: parse_date(params.due_date),
      created_at: DateTime.utc_now(),
      completed_at: nil
    }

    # Get current tasks directly from context state
    current_tasks = context.state.tasks || []

    # Create new state with added task
    new_state = %{tasks: [task | current_tasks]}
    {:ok, new_state}
  end

  def safe_parse_priority("low"), do: :low
  def safe_parse_priority("medium"), do: :medium
  def safe_parse_priority("high"), do: :high
  def safe_parse_priority(_), do: :medium

  defp parse_date(nil), do: nil

  defp parse_date(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _} ->
        datetime

      _error ->
        nil
    end
  end
end

defmodule JidoWorkbench.Actions.CompleteTask do
  require Logger

  use Jido.Action,
    name: "complete_task",
    description: "Mark a task as completed",
    schema: [
      task_id: [type: :string, required: true, doc: "ID of the task to complete"]
    ]

  def run(%{task_id: task_id}, %{state: state}) do
    Logger.metadata(action: "complete_task")

    case Enum.find_index(state.tasks, &(&1.id == task_id)) do
      nil ->
        {:error, :task_not_found}

      index ->
        task = Enum.at(state.tasks, index)
        updated_task = %{task | status: :completed, completed_at: DateTime.utc_now()}
        new_tasks = List.replace_at(state.tasks, index, updated_task)
        new_state = %{tasks: new_tasks}

        {:ok, new_state}
    end
  end
end

defmodule JidoWorkbench.Actions.ListTasks do
  require Logger

  use Jido.Action,
    name: "list_tasks",
    description: "List all tasks with optional filters",
    schema: [
      status: [
        type: :string,
        required: false,
        doc: "Filter by status (pending, in_progress, completed)"
      ],
      priority: [type: :string, required: false, doc: "Filter by priority (low, medium, high)"]
    ]

  def run(params, %{state: state} = _context) do
    Logger.metadata(action: "list_tasks")

    tasks =
      state.tasks
      |> filter_by_status(params.status)
      |> filter_by_priority(params.priority)
      |> Enum.sort_by(& &1.created_at, {:desc, DateTime})

    {:ok, %{result: tasks}}
  end

  defp filter_by_status(tasks, nil), do: tasks

  defp filter_by_status(tasks, status) do
    status_atom = String.to_existing_atom(status)
    Enum.filter(tasks, &(&1.status == status_atom))
  end

  defp filter_by_priority(tasks, nil), do: tasks

  defp filter_by_priority(tasks, priority) do
    priority_atom = String.to_existing_atom(priority)
    Enum.filter(tasks, &(&1.priority == priority_atom))
  end
end

defmodule JidoWorkbench.Actions.UpdateTask do
  require Logger

  use Jido.Action,
    name: "update_task",
    description: "Update an existing task's details",
    schema: [
      task_id: [type: :string, required: true, doc: "ID of the task to update"],
      title: [type: :string, required: false, doc: "New title"],
      description: [type: :string, required: false, doc: "New description"],
      priority: [type: :string, required: false, doc: "New priority level"],
      status: [type: :string, required: false, doc: "New status"],
      due_date: [type: :string, required: false, doc: "New due date in ISO8601 format"]
    ]

  def run(params, %{state: state} = _context) do
    Logger.metadata(action: "update_task")

    case Enum.find_index(state.tasks, &(&1.id == params.task_id)) do
      nil ->
        {:error, :task_not_found}

      index ->
        current_task = Enum.at(state.tasks, index)
        updated_task = update_task_fields(current_task, params)
        new_tasks = List.replace_at(state.tasks, index, updated_task)

        {:ok, %{tasks: new_tasks, result: updated_task}}
    end
  end

  defp update_task_fields(task, params) do
    %{
      task
      | title: params.title || task.title,
        description: params.description || task.description,
        priority: parse_enum(params.priority) || task.priority,
        status: parse_enum(params.status) || task.status,
        due_date: parse_date(params.due_date) || task.due_date
    }
  end

  defp parse_enum(nil), do: nil
  defp parse_enum(value), do: String.to_existing_atom(value)

  defp parse_date(nil), do: nil

  defp parse_date(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end
end
