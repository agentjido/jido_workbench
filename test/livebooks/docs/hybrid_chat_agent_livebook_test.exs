defmodule AgentJido.Livebooks.Docs.HybridChatAgentLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/hybrid-chat-agent.livemd",
    timeout: 120_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
