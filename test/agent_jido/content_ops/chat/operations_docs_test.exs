defmodule AgentJido.ContentOps.Chat.OperationsDocsTest do
  use ExUnit.Case, async: true

  @runbook_path Path.expand("../../../../specs/runbooks/chatops_runbook.md", __DIR__)
  @durability_note_path Path.expand("../../../../specs/runbooks/chatops_durability_decision.md", __DIR__)

  @required_env_vars [
    "CONTENTOPS_CHAT_ENABLED",
    "TELEGRAM_BOT_TOKEN",
    "DISCORD_BOT_TOKEN",
    "TELEGRAM_CHAT_ID",
    "DISCORD_CHANNEL_ID",
    "CONTENTOPS_ROOM_ID",
    "CONTENTOPS_ROOM_NAME"
  ]

  test "runbook documents required env vars, room mapping, and startup health checks" do
    runbook = File.read!(@runbook_path)

    Enum.each(@required_env_vars, fn env_var ->
      assert runbook =~ env_var
    end)

    assert runbook =~ "Room/Channel Mapping"
    assert runbook =~ "Startup Procedure"
    assert runbook =~ "Health Validation Checklist"
    assert runbook =~ "/dashboard/chatops"
    assert runbook =~ "/ops status"
  end

  test "durability note documents ETS posture and deferred durable migration" do
    note = File.read!(@durability_note_path)

    assert note =~ "Decision"
    assert note =~ "ETS"
    assert note =~ "Defer full durable storage migration"
    assert note =~ "Consequences"
    assert note =~ "Deferred Durable Path"
  end
end
