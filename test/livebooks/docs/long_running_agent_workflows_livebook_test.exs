defmodule AgentJido.Livebooks.Docs.LongRunningAgentWorkflowsLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/long-running-agent-workflows.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
