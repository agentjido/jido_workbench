defmodule AgentJido.ContentOps.Chat.TelegramHandler do
  @moduledoc """
  Telegram ingress handler for ContentOps chat.
  """

  use JidoMessaging.Channels.Telegram.Handler,
    messaging: AgentJido.ContentOps.Messaging,
    on_message: &AgentJido.ContentOps.Chat.Router.handle_message/2
end
