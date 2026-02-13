defmodule AgentJido.ContentOps.Chat.BindingBootstrapper do
  @moduledoc """
  Idempotently creates shared rooms, bindings, and room servers.
  """

  use GenServer

  require Logger

  @doc "Starts the bootstrapper process."
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc "Runs bootstrap immediately."
  @spec bootstrap() :: :ok
  def bootstrap do
    GenServer.cast(__MODULE__, :bootstrap)
  end

  @impl true
  def init(opts) do
    state = %{
      instance_module: Keyword.fetch!(opts, :instance_module),
      bindings: Keyword.get(opts, :bindings, []),
      telegram_instance_id: Keyword.get(opts, :telegram_instance_id, to_string(AgentJido.ContentOps.Chat.TelegramHandler)),
      discord_instance_id: Keyword.get(opts, :discord_instance_id, to_string(AgentJido.ContentOps.Chat.DiscordHandler))
    }

    send(self(), :bootstrap)

    {:ok, state}
  end

  @impl true
  def handle_cast(:bootstrap, state) do
    {:noreply, do_bootstrap(state)}
  end

  @impl true
  def handle_info(:bootstrap, state) do
    {:noreply, do_bootstrap(state)}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp do_bootstrap(state) do
    Enum.each(state.bindings, fn binding ->
      case ensure_binding(state.instance_module, binding, state) do
        :ok -> :ok
        {:error, reason} -> Logger.warning("[ContentOps.Chat.BindingBootstrapper] bootstrap failed: #{inspect(reason)}")
      end
    end)

    state
  end

  defp ensure_binding(messaging, binding, state) do
    with {:ok, room} <- ensure_room(messaging, binding),
         :ok <- ensure_room_binding(messaging, room.id, :telegram, state.telegram_instance_id, binding.telegram_chat_id),
         :ok <- ensure_room_binding(messaging, room.id, :discord, state.discord_instance_id, binding.discord_channel_id),
         {:ok, _pid} <- messaging.get_or_start_room_server(room) do
      :ok
    end
  end

  defp ensure_room(messaging, %{room_id: room_id, room_name: room_name}) do
    case messaging.get_room(room_id) do
      {:ok, room} ->
        {:ok, room}

      {:error, :not_found} ->
        room = %JidoMessaging.Room{
          id: room_id,
          type: :group,
          name: room_name,
          external_bindings: %{},
          metadata: %{},
          inserted_at: DateTime.utc_now()
        }

        messaging.save_room(room)
    end
  end

  defp ensure_room_binding(messaging, room_id, channel, instance_id, external_id) do
    external_id = to_string(external_id)

    case messaging.get_room_by_external_binding(channel, instance_id, external_id) do
      {:ok, %{id: ^room_id}} ->
        :ok

      {:ok, %{id: existing_room_id}} ->
        {:error, {:binding_conflict, channel, instance_id, external_id, existing_room_id, room_id}}

      {:error, :not_found} ->
        case messaging.create_room_binding(room_id, channel, instance_id, external_id, %{}) do
          {:ok, _binding} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end
end
