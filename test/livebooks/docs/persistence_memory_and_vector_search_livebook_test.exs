defmodule AgentJido.Livebooks.Docs.PersistenceMemoryAndVectorSearchLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/persistence-memory-and-vector-search.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
