defmodule AgentJido.Livebooks.Docs.DebuggingAndTroubleshootingLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/debugging-and-troubleshooting.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
