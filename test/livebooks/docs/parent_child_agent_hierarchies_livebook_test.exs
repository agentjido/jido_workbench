defmodule AgentJido.Livebooks.Docs.ParentChildAgentHierarchiesLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/parent-child-agent-hierarchies.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
