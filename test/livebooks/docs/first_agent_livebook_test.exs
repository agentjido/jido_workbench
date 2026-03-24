defmodule AgentJido.Livebooks.Docs.FirstAgentLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/getting-started/first-agent.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
