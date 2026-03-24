defmodule AgentJido.Livebooks.Docs.StateMachinesWithFSMLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/state-machines-with-fsm.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
