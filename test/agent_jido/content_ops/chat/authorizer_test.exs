defmodule AgentJido.ContentOps.Chat.AuthorizerTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.Chat.Authorizer

  setup do
    original = Application.get_env(:agent_jido, AgentJido.ContentOps.Chat)

    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      bindings: [],
      allowed_telegram_user_ids: ["111"],
      allowed_discord_user_ids: ["222"],
      bot_name: "ContentOps",
      command_prefix: "/ops"
    )

    on_exit(fn ->
      if is_nil(original) do
        Application.delete_env(:agent_jido, AgentJido.ContentOps.Chat)
      else
        Application.put_env(:agent_jido, AgentJido.ContentOps.Chat, original)
      end
    end)

    :ok
  end

  test "allowed_to_mutate?/1 allows configured telegram user" do
    assert Authorizer.allowed_to_mutate?(%{channel: :telegram, external_user_id: "111"})
  end

  test "allowed_to_mutate?/1 denies unknown user" do
    refute Authorizer.allowed_to_mutate?(%{channel: :telegram, external_user_id: "999"})
  end

  test "actor_from_context/1 extracts actor identity" do
    context = %{
      channel: JidoMessaging.Channels.Discord,
      participant: %{external_ids: %{discord: "222"}}
    }

    assert %{channel: :discord, external_user_id: "222"} = Authorizer.actor_from_context(context)
  end
end
