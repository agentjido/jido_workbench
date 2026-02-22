defmodule AgentJidoWeb.Presence do
  @moduledoc """
  Presence tracker for first-party real-time site activity.
  """
  use Phoenix.Presence,
    otp_app: :agent_jido,
    pubsub_server: AgentJido.PubSub
end
