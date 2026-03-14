defmodule AgentJido.Livebooks.Docs.PluginsAndComposableAgentsLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/plugins-and-composable-agents.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
