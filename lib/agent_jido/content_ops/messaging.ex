defmodule AgentJido.ContentOps.Messaging do
  @moduledoc """
  Messaging instance for ContentOps chat integrations.

  Uses in-memory ETS storage in V1.
  """

  use Jido.Messaging,
    persistence: Jido.Messaging.Persistence.ETS,
    pubsub: AgentJido.PubSub
end
