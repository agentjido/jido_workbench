defmodule AgentJido.Livebooks.Docs.RetriesBackpressureAndFailureRecoveryLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/retries-backpressure-and-failure-recovery.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
