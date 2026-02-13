defmodule AgentJido.ContentOps.Chat.MessagePublisher do
  @moduledoc """
  Publishes internal assistant messages into messaging rooms.

  Messages added through this module are bridged to configured channels by
  `AgentJido.ContentOps.Chat.Bridge`.
  """

  alias AgentJido.ContentOps.Chat.Config
  alias AgentJido.ContentOps.Messaging
  alias JidoMessaging.{Content.Text, RoomServer}

  @sender_id "contentops_chat"

  @doc "Publish a text message to a ContentOps chat room."
  @spec publish(String.t(), String.t(), map()) :: {:ok, JidoMessaging.Message.t()} | {:error, term()}
  def publish(room_id, text, metadata \\ %{}) when is_binary(room_id) and is_binary(text) and is_map(metadata) do
    with {:ok, room} <- Messaging.get_room(room_id),
         {:ok, room_server} <- Messaging.get_or_start_room_server(room),
         {:ok, message} <- Messaging.save_message(build_attrs(room_id, text, metadata)) do
      :ok = RoomServer.add_message(room_server, message)
      {:ok, message}
    end
  end

  defp build_attrs(room_id, text, metadata) do
    bot_name = Config.load!().bot_name

    %{
      room_id: room_id,
      sender_id: @sender_id,
      role: :assistant,
      content: [%Text{text: text}],
      status: :sent,
      metadata:
        Map.merge(
          %{
            channel: :agent,
            username: bot_name,
            display_name: bot_name,
            agent_name: bot_name
          },
          metadata
        )
    }
  end
end
