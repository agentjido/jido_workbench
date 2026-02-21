defmodule AgentJido.Livebooks.Docs.AgentRuntimeLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/concepts/agent-runtime.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
