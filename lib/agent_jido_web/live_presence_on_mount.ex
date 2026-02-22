defmodule AgentJidoWeb.LivePresenceOnMount do
  @moduledoc """
  LiveView on-mount hook that tracks connected sockets in site presence.
  """

  alias AgentJidoWeb.SitePresence

  @spec on_mount(atom(), map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:cont, Phoenix.LiveView.Socket.t()}
  def on_mount(:track_live_presence, _params, _session, socket) do
    if Phoenix.LiveView.connected?(socket) do
      case SitePresence.track_socket(socket) do
        {:ok, _meta} ->
          :ok

        {:error, {:already_tracked, _pid, _topic, _key}} ->
          :ok

        {:error, _reason} ->
          :ok
      end
    end

    {:cont, socket}
  end
end
