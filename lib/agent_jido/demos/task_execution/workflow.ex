defmodule AgentJido.Demos.TaskExecution.Workflow do
  @moduledoc """
  Deterministic task lifecycle workflow built on the shipped task-list actions.

  The demo keeps all state local and uses `Jido.Exec.run/3` for the same
  task transitions users can copy into their own projects.
  """

  alias AgentJido.Demos.TaskExecution.{
    AddTasks,
    CompleteTask,
    GetState,
    NextTask,
    StartTask
  }

  defstruct tasks: [],
            state: %{
              tasks: [],
              summary: %{total: 0, pending: 0, in_progress: 0, done: 0, blocked: 0},
              all_complete: false
            },
            next: %{status: "no_tasks", message: "No tasks in the list. Add tasks first."},
            log: [],
            completion_count: 0

  @type task :: map()
  @type log_entry :: %{
          required(:label) => String.t(),
          required(:detail) => String.t()
        }

  @type t :: %__MODULE__{
          tasks: [task()],
          state: map(),
          next: map(),
          log: [log_entry()],
          completion_count: non_neg_integer()
        }

  @seed_tasks [
    %{
      title: "Validate release metadata",
      description: "Check mix.exs version, changelog notes, and package metadata.",
      priority: 10
    },
    %{
      title: "Run quality gates",
      description: "Run tests and quality checks before publishing.",
      priority: 20
    },
    %{
      title: "Publish beta package",
      description: "Perform dry run and publish to Hex with release notes.",
      priority: 30
    }
  ]

  @max_iterations 12

  @doc "Builds a new empty workflow state and computes the initial task summary."
  @spec new() :: t()
  def new do
    refresh(%__MODULE__{})
  end

  @doc "Seeds the deterministic release tasks used by the public example."
  @spec seed_tasks(t()) :: t()
  def seed_tasks(%__MODULE__{tasks: []} = workflow) do
    {:ok, add_result} = Jido.Exec.run(AddTasks, %{tasks: @seed_tasks}, %{})

    workflow
    |> Map.put(:tasks, add_result.created_tasks)
    |> append_log("Seed tasks", add_result.message)
    |> refresh()
  end

  def seed_tasks(%__MODULE__{} = workflow) do
    workflow
    |> append_log("Seed tasks", "Task list already exists. Reset the demo to reseed.")
    |> refresh()
  end

  @doc "Starts the next pending task when the workflow has work available."
  @spec start_next_task(t()) :: t()
  def start_next_task(%__MODULE__{} = workflow) do
    case workflow.next.status do
      "next_task" ->
        task = workflow.next.task
        {:ok, started} = Jido.Exec.run(StartTask, %{task_id: task["id"]}, context(workflow.tasks))

        workflow
        |> Map.put(:tasks, replace_task(workflow.tasks, started.task))
        |> append_log("Start task", started.message)
        |> refresh()

      "no_tasks" ->
        workflow
        |> append_log("Start task", "Seed the task list before starting work.")
        |> refresh()

      "tasks_in_progress" ->
        workflow
        |> append_log("Start task", "#{length(workflow.next.in_progress)} task(s) are already in progress.")
        |> refresh()

      "all_complete" ->
        workflow
        |> append_log("Start task", "All tasks are already complete.")
        |> refresh()

      other ->
        workflow
        |> append_log("Start task", "Unexpected next-task state: #{inspect(other)}")
        |> refresh()
    end
  end

  @doc "Completes the current in-progress task and records a deterministic result."
  @spec complete_active_task(t()) :: t()
  def complete_active_task(%__MODULE__{} = workflow) do
    case Enum.find(workflow.tasks, &(&1["status"] == "in_progress")) do
      nil ->
        workflow
        |> append_log("Complete task", "No in-progress task to complete.")
        |> refresh()

      task ->
        result = "Completed workflow step #{workflow.completion_count + 1} for #{task["title"]}."

        {:ok, completed} =
          Jido.Exec.run(
            CompleteTask,
            %{task_id: task["id"], result: result},
            context(workflow.tasks)
          )

        workflow
        |> Map.put(:tasks, replace_task(workflow.tasks, completed.task))
        |> Map.put(:completion_count, workflow.completion_count + 1)
        |> append_log("Complete task", completed.message)
        |> refresh()
    end
  end

  @doc "Runs the seeded workflow until the task list reaches the all-complete state."
  @spec run_to_completion(t()) :: t()
  def run_to_completion(%__MODULE__{} = workflow) do
    workflow =
      if workflow.tasks == [] do
        seed_tasks(workflow)
      else
        workflow
      end

    do_run_to_completion(workflow, 0)
  end

  @doc "Resets the demo back to an empty workflow state."
  @spec reset() :: t()
  def reset, do: new()

  defp do_run_to_completion(%__MODULE__{} = workflow, iteration) when iteration >= @max_iterations do
    workflow
    |> append_log("Run full workflow", "Stopped after #{@max_iterations} iterations to avoid an infinite loop.")
    |> refresh()
  end

  defp do_run_to_completion(%__MODULE__{next: %{status: "all_complete"}} = workflow, _iteration) do
    workflow
    |> append_log("Run full workflow", "Workflow reached all_complete.")
    |> refresh()
  end

  defp do_run_to_completion(%__MODULE__{} = workflow, iteration) do
    workflow =
      workflow
      |> start_next_task()
      |> complete_active_task()

    if workflow.next.status == "all_complete" do
      workflow
      |> append_log("Run full workflow", "Workflow reached all_complete.")
      |> refresh()
    else
      do_run_to_completion(workflow, iteration + 1)
    end
  end

  defp refresh(%__MODULE__{} = workflow) do
    {:ok, state} = Jido.Exec.run(GetState, %{}, context(workflow.tasks))
    {:ok, next_task} = Jido.Exec.run(NextTask, %{}, context(workflow.tasks))

    %{workflow | state: state, next: next_task}
  end

  defp context(tasks), do: %{tasks: tasks}

  defp replace_task(tasks, updated_task) do
    Enum.map(tasks, fn task ->
      if task["id"] == updated_task["id"], do: updated_task, else: task
    end)
  end

  defp append_log(%__MODULE__{} = workflow, label, detail) do
    entry = %{label: label, detail: detail}
    %{workflow | log: [entry | workflow.log] |> Enum.take(40)}
  end
end
