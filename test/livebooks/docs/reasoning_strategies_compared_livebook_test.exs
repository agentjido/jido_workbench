defmodule AgentJido.Livebooks.Docs.ReasoningStrategiesComparedLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/reasoning-strategies-compared.livemd",
    timeout: 180_000,
    external: true,
    required_any_env: ["OPENAI_API_KEY", "LB_OPENAI_API_KEY"]

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
