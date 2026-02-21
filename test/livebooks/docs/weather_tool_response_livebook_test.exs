defmodule AgentJido.Livebooks.Docs.WeatherToolResponseLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/guides/cookbook/weather-tool-response.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
