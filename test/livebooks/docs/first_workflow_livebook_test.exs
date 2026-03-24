defmodule AgentJido.Livebooks.Docs.FirstWorkflowLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/first-workflow.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
