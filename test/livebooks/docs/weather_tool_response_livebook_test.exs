defmodule AgentJido.Livebooks.Docs.WeatherToolResponseLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/cookbook/weather-tool-response.livemd",
    timeout: 120_000,
    external: true,
    required_any_env: ["OPENAI_API_KEY", "LB_OPENAI_API_KEY"]

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
