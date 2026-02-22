defmodule AgentJidoWeb.AnalyticsOnMount do
  @moduledoc """
  LiveView on-mount hook that exposes analytics identity to sockets.
  """

  import Phoenix.Component, only: [assign: 3]

  @spec on_mount(atom(), map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:cont, Phoenix.LiveView.Socket.t()}
  def on_mount(:mount_analytics_identity, _params, session, socket) do
    identity =
      session
      |> Map.get("analytics_identity", %{})
      |> normalize_identity()

    {:cont, assign(socket, :analytics_identity, identity)}
  end

  defp normalize_identity(identity) when is_map(identity) do
    %{
      visitor_id: read(identity, "visitor_id"),
      session_id: read(identity, "session_id"),
      path: read(identity, "path"),
      referrer_host: read(identity, "referrer_host")
    }
  end

  defp normalize_identity(_), do: %{visitor_id: nil, session_id: nil, path: nil, referrer_host: nil}

  defp read(map, key) do
    Map.get(map, key) || Map.get(map, String.to_atom(key))
  rescue
    ArgumentError -> Map.get(map, key)
  end
end
