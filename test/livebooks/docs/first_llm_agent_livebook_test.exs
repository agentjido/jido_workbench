defmodule AgentJido.Livebooks.Docs.FirstLLMAgentLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/getting-started/first-llm-agent.livemd",
    timeout: 120_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
