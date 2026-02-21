defmodule AgentJido.Livebooks.Docs.SignalsLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/concepts/signals.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
