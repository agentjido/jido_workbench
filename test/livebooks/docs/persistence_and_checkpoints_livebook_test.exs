defmodule AgentJido.Livebooks.Docs.PersistenceAndCheckpointsLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/persistence-and-checkpoints.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
