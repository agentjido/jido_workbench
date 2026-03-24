defmodule AgentJido.Livebooks.Docs.TaskPlanningAndExecutionLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/task-planning-and-execution.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
