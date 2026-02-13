defmodule AgentJido.ContentOps.Messaging do
  @moduledoc """
  Messaging instance for ContentOps chat integrations.

  Uses in-memory ETS storage in V1.
  """

  use JidoMessaging,
    adapter: JidoMessaging.Adapters.ETS,
    pubsub: AgentJido.PubSub
end
