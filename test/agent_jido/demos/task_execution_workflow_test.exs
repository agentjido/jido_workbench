defmodule AgentJido.Demos.TaskExecutionWorkflowTest do
  use ExUnit.Case, async: false

  alias AgentJido.Demos.TaskExecution.Workflow

  test "seed_tasks creates the deterministic release workflow and exposes the next task" do
    workflow = Workflow.new() |> Workflow.seed_tasks()

    assert length(workflow.tasks) == 3
    assert workflow.state.summary.total == 3
    assert workflow.state.summary.pending == 3
    assert workflow.state.summary.done == 0
    assert workflow.next.status == "next_task"
    assert workflow.next.task["title"] == "Validate release metadata"

    assert Enum.any?(workflow.log, fn entry ->
             entry.label == "Seed tasks" and entry.detail == "Added 3 task(s) to the list."
           end)
  end

  test "start_next_task and complete_active_task advance the lifecycle" do
    workflow =
      Workflow.new()
      |> Workflow.seed_tasks()
      |> Workflow.start_next_task()

    assert workflow.state.summary.in_progress == 1
    assert Enum.any?(workflow.tasks, &(&1["status"] == "in_progress"))

    workflow = Workflow.complete_active_task(workflow)

    assert workflow.state.summary.pending == 2
    assert workflow.state.summary.in_progress == 0
    assert workflow.state.summary.done == 1
    assert Enum.any?(workflow.tasks, &(&1["status"] == "done"))

    assert Enum.any?(workflow.log, fn entry ->
             entry.label == "Complete task" and String.contains?(entry.detail, "Completed task:")
           end)
  end

  test "run_to_completion reaches the all-complete terminal state" do
    workflow = Workflow.new() |> Workflow.run_to_completion()

    assert workflow.state.all_complete == true
    assert workflow.state.summary.total == 3
    assert workflow.state.summary.done == 3
    assert Enum.all?(workflow.tasks, &(&1["status"] == "done"))
    assert workflow.next.status == "all_complete"

    assert Enum.any?(workflow.log, fn entry ->
             entry.label == "Run full workflow" and entry.detail == "Workflow reached all_complete."
           end)
  end
end
