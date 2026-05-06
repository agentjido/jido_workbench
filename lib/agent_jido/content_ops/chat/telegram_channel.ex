defmodule AgentJido.ContentOps.Chat.TelegramChannel do
  @moduledoc """
  Telegram adapter used by the ContentOps chat integration.
  """

  use Jido.Chat.Adapter

  require Logger

  @impl true
  def channel_type, do: :telegram

  @impl true
  def capabilities do
    %{
      send_message: :native,
      edit_message: :native,
      verify_webhook: :fallback,
      parse_event: :fallback,
      format_webhook_response: :fallback
    }
  end

  @impl true
  def transform_incoming(%Telegex.Type.Update{message: nil}) do
    {:error, :no_message}
  end

  def transform_incoming(%Telegex.Type.Update{message: message}) do
    transform_message(message)
  end

  def transform_incoming(%{message: nil}) do
    {:error, :no_message}
  end

  def transform_incoming(%{message: message}) when is_map(message) do
    transform_message_map(message)
  end

  def transform_incoming(%{"message" => nil}) do
    {:error, :no_message}
  end

  def transform_incoming(%{"message" => message}) when is_map(message) do
    transform_message_map(message)
  end

  def transform_incoming(_update) do
    {:error, :unsupported_update_type}
  end

  @impl true
  def send_message(chat_id, text, opts \\ []) do
    telegram_opts = Keyword.take(opts, [:parse_mode, :reply_to_message_id, :disable_notification, :reply_markup])

    case Telegex.send_message(chat_id, text, telegram_opts) do
      {:ok, sent_message} ->
        {:ok, %{message_id: sent_message.message_id, chat_id: sent_message.chat.id, date: sent_message.date}}

      {:error, reason} ->
        Logger.warning("[ContentOps.Telegram] send_message failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @impl true
  def edit_message(chat_id, message_id, text, opts \\ []) do
    telegram_opts =
      opts
      |> Keyword.take([:parse_mode, :reply_markup])
      |> Keyword.put(:chat_id, chat_id)
      |> Keyword.put(:message_id, message_id)

    case Telegex.edit_message_text(text, telegram_opts) do
      {:ok, %Telegex.Type.Message{} = edited_message} ->
        {:ok, %{message_id: edited_message.message_id, chat_id: edited_message.chat.id, date: edited_message.date}}

      {:ok, true} ->
        {:ok, %{message_id: message_id, chat_id: chat_id}}

      {:error, reason} ->
        Logger.warning("[ContentOps.Telegram] edit_message_text failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp transform_message(%Telegex.Type.Message{} = msg) do
    {:ok,
     %{
       external_room_id: msg.chat.id,
       external_user_id: get_user_id(msg),
       text: msg.text,
       media: [],
       username: get_username(msg),
       display_name: get_display_name(msg),
       external_message_id: msg.message_id,
       timestamp: msg.date,
       chat_type: parse_chat_type(msg.chat.type),
       chat_title: msg.chat.title,
       raw: Map.from_struct(msg)
     }}
  end

  defp transform_message_map(msg) when is_map(msg) do
    chat = Map.get(msg, :chat) || Map.get(msg, "chat", %{})
    from = Map.get(msg, :from) || Map.get(msg, "from", %{})

    {:ok,
     %{
       external_room_id: get_map_value(chat, [:id, "id"]),
       external_user_id: get_map_value(from, [:id, "id"]),
       text: get_map_value(msg, [:text, "text"]),
       media: [],
       username: get_map_value(from, [:username, "username"]),
       display_name: get_map_value(from, [:first_name, "first_name"]),
       external_message_id: get_map_value(msg, [:message_id, "message_id"]),
       timestamp: get_map_value(msg, [:date, "date"]),
       chat_type: parse_chat_type(get_map_value(chat, [:type, "type"])),
       chat_title: get_map_value(chat, [:title, "title"]),
       raw: msg
     }}
  end

  defp get_user_id(%{from: %{id: id}}), do: id
  defp get_user_id(_), do: nil

  defp get_username(%{from: %{username: username}}), do: username
  defp get_username(_), do: nil

  defp get_display_name(%{from: %{first_name: first_name}}), do: first_name
  defp get_display_name(_), do: nil

  defp get_map_value(map, keys) when is_map(map), do: Enum.find_value(keys, &Map.get(map, &1))
  defp get_map_value(_map, _keys), do: nil

  defp parse_chat_type("private"), do: :private
  defp parse_chat_type("group"), do: :group
  defp parse_chat_type("supergroup"), do: :supergroup
  defp parse_chat_type("channel"), do: :channel
  defp parse_chat_type(:private), do: :private
  defp parse_chat_type(:group), do: :group
  defp parse_chat_type(:supergroup), do: :supergroup
  defp parse_chat_type(:channel), do: :channel
  defp parse_chat_type(_), do: :unknown
end
