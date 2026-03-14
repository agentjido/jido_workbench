defmodule AgentJido.ContentOps.Chat.TelegramHandler do
  @moduledoc """
  Telegram ingress handler for ContentOps chat.
  """

  alias AgentJido.ContentOps.Chat.Router

  use JidoMessaging.Channels.Telegram.Handler,
    messaging: AgentJido.ContentOps.Messaging,
    on_message: &Router.handle_message/2
end
