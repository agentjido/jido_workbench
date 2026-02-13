defmodule AgentJido.ContentOps.Chat.PolicyTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.Chat.Policy

  setup do
    original = Application.get_env(:agent_jido, AgentJido.ContentOps.Chat)

    on_exit(fn ->
      if is_nil(original) do
        Application.delete_env(:agent_jido, AgentJido.ContentOps.Chat)
      else
        Application.put_env(:agent_jido, AgentJido.ContentOps.Chat, original)
      end
    end)

    :ok
  end

  test "authorize_mutation/1 allows configured actor when mutation tools are enabled" do
    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      mutation_tools_enabled: true,
      bindings: [],
      allowed_telegram_user_ids: ["111"],
      allowed_discord_user_ids: [],
      bot_name: "ContentOps",
      command_prefix: "/ops"
    )

    assert :ok = Policy.authorize_mutation(%{channel: :telegram, external_user_id: "111"})
  end

  test "authorize_mutation/1 denies actor not in allowlist" do
    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      mutation_tools_enabled: true,
      bindings: [],
      allowed_telegram_user_ids: ["111"],
      allowed_discord_user_ids: [],
      bot_name: "ContentOps",
      command_prefix: "/ops"
    )

    assert {:error, :unauthorized} =
             Policy.authorize_mutation(%{channel: :telegram, external_user_id: "999"})
  end

  test "authorize_mutation/1 denies when mutation tools are disabled" do
    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      mutation_tools_enabled: false,
      bindings: [],
      allowed_telegram_user_ids: ["111"],
      allowed_discord_user_ids: [],
      bot_name: "ContentOps",
      command_prefix: "/ops"
    )

    assert {:error, :mutations_disabled} =
             Policy.authorize_mutation(%{channel: :telegram, external_user_id: "111"})
  end
end
