defmodule AgentJido.Livebooks.Docs.DirectivesLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/concepts/directives.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
