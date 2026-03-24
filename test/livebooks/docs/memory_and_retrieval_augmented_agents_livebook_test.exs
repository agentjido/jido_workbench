defmodule AgentJido.Livebooks.Docs.MemoryAndRetrievalAugmentedAgentsLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/memory-and-retrieval-augmented-agents.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
