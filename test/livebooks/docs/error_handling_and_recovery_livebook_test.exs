defmodule AgentJido.Livebooks.Docs.ErrorHandlingAndRecoveryLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/error-handling-and-recovery.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
