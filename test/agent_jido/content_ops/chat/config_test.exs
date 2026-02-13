defmodule AgentJido.ContentOps.Chat.ConfigTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.Chat.Config

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

  test "load!/0 parses valid config" do
    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      bindings: [
        %{
          "room_id" => "contentops:lobby",
          "room_name" => "ContentOps Lobby",
          "telegram_chat_id" => "123",
          "discord_channel_id" => "456"
        }
      ],
      allowed_telegram_user_ids: ["1", "2"],
      allowed_discord_user_ids: "3,4",
      bot_name: "OpsBot",
      command_prefix: "ops",
      github_owner: "agentjido",
      github_repo: "agentjido_xyz",
      github_labels_base: ["contentops", "chatops"],
      github_labels_docs_note: "docs-note,triage",
      mutation_tools_enabled: true
    )

    cfg = Config.load!()

    assert cfg.enabled == true
    assert length(cfg.bindings) == 1
    assert hd(cfg.bindings).room_id == "contentops:lobby"
    assert MapSet.member?(cfg.allowed_telegram_user_ids, "1")
    assert MapSet.member?(cfg.allowed_discord_user_ids, "4")
    assert cfg.bot_name == "OpsBot"
    assert cfg.command_prefix == "/ops"
    assert cfg.github_owner == "agentjido"
    assert cfg.github_repo == "agentjido_xyz"
    assert cfg.github_labels_base == ["contentops", "chatops"]
    assert cfg.github_labels_docs_note == ["docs-note", "triage"]
    assert cfg.mutation_tools_enabled == true
  end

  test "load!/0 rejects malformed bindings" do
    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      bindings: [%{"room_id" => "x"}]
    )

    assert_raise ArgumentError, ~r/Missing required ContentOps chat binding field/, fn ->
      Config.load!()
    end
  end

  test "load!/0 rejects duplicate room ids" do
    Application.put_env(:agent_jido, AgentJido.ContentOps.Chat,
      enabled: true,
      bindings: [
        %{"room_id" => "dup", "room_name" => "A", "telegram_chat_id" => "1", "discord_channel_id" => "2"},
        %{"room_id" => "dup", "room_name" => "B", "telegram_chat_id" => "3", "discord_channel_id" => "4"}
      ]
    )

    assert_raise ArgumentError, ~r/duplicate room_id/, fn ->
      Config.load!()
    end
  end
end
