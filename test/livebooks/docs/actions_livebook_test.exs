defmodule AgentJido.Livebooks.Docs.ActionsLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/concepts/actions.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
