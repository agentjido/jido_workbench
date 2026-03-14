defmodule AgentJido.ContentOps.Chat.DiscordHandler do
  @moduledoc """
  Discord ingress handler for ContentOps chat.
  """

  alias AgentJido.ContentOps.Chat.Router

  use JidoMessaging.Channels.Discord.Handler,
    messaging: AgentJido.ContentOps.Messaging,
    on_message: &Router.handle_message/2
end
