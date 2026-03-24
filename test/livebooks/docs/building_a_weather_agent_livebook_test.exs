defmodule AgentJido.Livebooks.Docs.BuildingAWeatherAgentLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/building-a-weather-agent.livemd",
    timeout: 180_000,
    external: true,
    required_any_env: ["OPENAI_API_KEY", "LB_OPENAI_API_KEY"]

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
