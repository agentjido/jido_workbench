defmodule AgentJido.Livebooks.Docs.GettingStartedLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/getting-started.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
