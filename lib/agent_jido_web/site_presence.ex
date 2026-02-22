defmodule AgentJidoWeb.SitePresence do
  @moduledoc """
  Site-wide presence helpers for tracking active visitors and sessions.
  """

  alias AgentJidoWeb.Presence

  @topic "site:presence"

  @type snapshot :: %{active_visitors: non_neg_integer(), active_sessions: non_neg_integer()}

  @spec topic() :: String.t()
  def topic, do: @topic

  @spec subscribe() :: :ok | {:error, term()}
  def subscribe do
    Phoenix.PubSub.subscribe(AgentJido.PubSub, @topic)
  end

  @spec track_socket(Phoenix.LiveView.Socket.t()) :: {:ok, map()} | {:error, term()}
  def track_socket(socket) do
    Presence.track(self(), @topic, presence_key(socket), presence_meta(socket))
  end

  @spec snapshot() :: snapshot()
  def snapshot do
    presences = Presence.list(@topic)

    %{
      active_visitors: map_size(presences),
      active_sessions: session_count(presences)
    }
  end

  defp session_count(presences) when is_map(presences) do
    Enum.reduce(presences, 0, fn {_key, presence}, acc ->
      metas = Map.get(presence, :metas) || Map.get(presence, "metas") || []
      acc + length(metas)
    end)
  end

  defp presence_key(socket) do
    user_id = socket |> current_user_id() |> normalize_identity()
    visitor_id = socket |> analytics_value(:visitor_id) |> normalize_identity()
    session_id = socket |> analytics_value(:session_id) |> normalize_identity()

    cond do
      is_binary(user_id) -> "user:" <> user_id
      is_binary(visitor_id) -> "visitor:" <> visitor_id
      is_binary(session_id) -> "session:" <> session_id
      true -> "socket:" <> Ecto.UUID.generate()
    end
  end

  defp presence_meta(socket) do
    %{
      connected_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      view: inspect(socket.view),
      path: analytics_value(socket, :path),
      user_id: current_user_id(socket),
      visitor_id: analytics_value(socket, :visitor_id),
      session_id: analytics_value(socket, :session_id)
    }
  end

  defp current_user_id(socket) do
    case socket.assigns[:current_scope] do
      %{user: %{id: user_id}} when is_binary(user_id) -> user_id
      _ -> nil
    end
  end

  defp analytics_value(socket, key) do
    identity = socket.assigns[:analytics_identity] || %{}
    Map.get(identity, key) || Map.get(identity, Atom.to_string(key))
  end

  defp normalize_identity(value) when is_binary(value) do
    trimmed = String.trim(value)
    if trimmed == "", do: nil, else: trimmed
  end

  defp normalize_identity(_value), do: nil
end
