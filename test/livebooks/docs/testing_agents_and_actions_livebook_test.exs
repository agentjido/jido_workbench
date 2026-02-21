defmodule AgentJido.Livebooks.Docs.TestingAgentsAndActionsLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/testing-agents-and-actions.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
