defmodule AgentJido.ContentOps.Chat.IntegrationTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.Messaging
  alias AgentJido.ContentOps.Chat.{BindingBootstrapper, Bridge, RunNotifier, RunStore, SessionManager}
  alias JidoMessaging.RoomServer

  defmodule TelegramStub do
    def send_message(external_id, text, _opts \\ []) do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, {:telegram_sent, to_string(external_id), text})
      {:ok, %{}}
    end
  end

  defmodule DiscordStub do
    def send_message(external_id, text, _opts \\ []) do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, {:discord_sent, to_string(external_id), text})
      {:ok, %{}}
    end
  end

  defmodule PublisherStub do
    def publish(room_id, text, metadata) do
      pid = Application.fetch_env!(:agent_jido, __MODULE__)[:pid]
      send(pid, {:published, room_id, text, metadata})
      {:ok, %{id: "stub"}}
    end
  end

  setup do
    start_supervised!(Messaging)
    start_supervised!(SessionManager)

    :ok
  end

  test "bootstrapper creates room bindings idempotently" do
    room_id = "contentops:test:" <> Integer.to_string(System.unique_integer([:positive]))

    bindings = [
      %{
        room_id: room_id,
        room_name: "Test Lobby",
        telegram_chat_id: "1001",
        discord_channel_id: "2001"
      }
    ]

    start_supervised!(
      {BindingBootstrapper, instance_module: Messaging, bindings: bindings, telegram_instance_id: "tg-test", discord_instance_id: "dc-test"}
    )

    Process.sleep(100)

    assert {:ok, _room} = Messaging.get_room(room_id)
    assert {:ok, room_bindings} = Messaging.list_room_bindings(room_id)
    assert length(room_bindings) == 2

    BindingBootstrapper.bootstrap()
    Process.sleep(100)

    assert {:ok, room_bindings_after} = Messaging.list_room_bindings(room_id)
    assert length(room_bindings_after) == 2
  end

  test "bridge forwards to non-origin channel only" do
    Application.put_env(:agent_jido, TelegramStub, pid: self())
    Application.put_env(:agent_jido, DiscordStub, pid: self())

    on_exit(fn ->
      Application.delete_env(:agent_jido, TelegramStub)
      Application.delete_env(:agent_jido, DiscordStub)
    end)

    room_id = "contentops:bridge:" <> Integer.to_string(System.unique_integer([:positive]))

    room = %JidoMessaging.Room{
      id: room_id,
      type: :group,
      name: "Bridge Test",
      external_bindings: %{},
      metadata: %{},
      inserted_at: DateTime.utc_now()
    }

    assert {:ok, room} = Messaging.save_room(room)
    assert {:ok, _} = Messaging.create_room_binding(room_id, :telegram, "tg-test", "111", %{})
    assert {:ok, _} = Messaging.create_room_binding(room_id, :discord, "dc-test", "222", %{})

    {:ok, room_server} = Messaging.get_or_start_room_server(room)

    start_supervised!({Bridge, name: :contentops_bridge_test, instance_module: Messaging, telegram_sender: TelegramStub, discord_sender: DiscordStub})

    Process.sleep(100)

    {:ok, message} =
      Messaging.save_message(%{
        room_id: room_id,
        sender_id: "user-1",
        role: :user,
        content: [%JidoMessaging.Content.Text{text: "hello bridge"}],
        status: :sent,
        metadata: %{channel: :telegram, username: "alice"}
      })

    :ok = RoomServer.add_message(room_server, message)

    assert_receive {:discord_sent, "222", "[TG alice] hello bridge"}, 1_000
    refute_receive {:telegram_sent, "111", _text}, 200
  end

  test "run report updates run store and publishes via notifier" do
    Application.put_env(:agent_jido, PublisherStub, pid: self())

    on_exit(fn ->
      Application.delete_env(:agent_jido, PublisherStub)
    end)

    start_supervised!({RunStore, subscribe: true})
    RunStore.clear()

    start_supervised!({RunNotifier, room_ids: ["contentops:lobby"], publisher: PublisherStub})

    report = %{
      run_id: "run_test_1",
      mode: :weekly,
      stats: %{change_requests: 1, delivered: 1},
      completed_at: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(AgentJido.PubSub, "contentops:runs", {:contentops_run_completed, report})

    assert_receive {:published, "contentops:lobby", text, _metadata}, 1_000
    assert text =~ "run_test_1"

    [stored | _] = RunStore.recent(1)
    assert stored.run_id == "run_test_1"
  end
end
