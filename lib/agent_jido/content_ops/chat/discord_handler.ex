defmodule AgentJido.ContentOps.Chat.DiscordHandler do
  @moduledoc """
  Discord ingress handler for ContentOps chat.
  """

  use JidoMessaging.Channels.Discord.Handler,
    messaging: AgentJido.ContentOps.Messaging,
    on_message: &AgentJido.ContentOps.Chat.Router.handle_message/2
end
