defmodule AgentJido.ContentOps.Chat.TestBootDeterminismTest do
  use ExUnit.Case, async: false

  test "chat subsystem remains disabled by default in MIX_ENV=test" do
    chat_cfg = Application.get_env(:agent_jido, AgentJido.ContentOps.Chat, [])

    refute config_enabled?(chat_cfg)
    refute Process.whereis(AgentJido.ContentOps.Chat.Supervisor)
  end

  defp config_enabled?(cfg) when is_list(cfg), do: Keyword.get(cfg, :enabled, false)
  defp config_enabled?(cfg) when is_map(cfg), do: Map.get(cfg, :enabled, false)
  defp config_enabled?(_cfg), do: false
end
