defmodule AgentJido.Livebooks.Docs.ToolResponseLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/cookbook/tool-response.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
