defmodule AgentJido.Livebooks.Docs.ChatResponseLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/cookbook/chat-response.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
