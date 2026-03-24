defmodule AgentJido.Livebooks.Docs.MultiAgentOrchestrationLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/multi-agent-orchestration.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
