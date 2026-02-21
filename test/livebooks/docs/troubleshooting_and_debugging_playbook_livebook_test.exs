defmodule AgentJido.Livebooks.Docs.TroubleshootingAndDebuggingPlaybookLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/troubleshooting-and-debugging-playbook.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
