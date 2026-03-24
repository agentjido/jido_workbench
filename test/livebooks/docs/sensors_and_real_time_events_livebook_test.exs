defmodule AgentJido.Livebooks.Docs.SensorsAndRealTimeEventsLivebookTest do
  use AgentJido.LivebookCase,
    livebook: "priv/pages/docs/learn/sensors-and-real-time-events.livemd",
    timeout: 60_000

  test "runs cleanly" do
    assert :ok = run_livebook()
  end
end
