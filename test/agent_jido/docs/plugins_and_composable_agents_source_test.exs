defmodule AgentJido.Docs.PluginsAndComposableAgentsSourceTest do
  use ExUnit.Case, async: true

  @source_path Path.expand("../../../priv/pages/docs/learn/plugins-and-composable-agents.livemd", __DIR__)

  test "signal routing section uses the runtime instance name" do
    source = File.read!(@source_path)

    assert source =~ "Jido.start_agent(runtime_name, MyApp.NotesAgent, id: \"notes-demo\")"
    refute source =~ "Jido.start_agent(jido, MyApp.NotesAgent, id: \"notes-demo\")"
    assert source =~ "expects the runtime instance name, not that pid"
  end
end
