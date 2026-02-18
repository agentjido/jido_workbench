defmodule AgentJido.ContentOps.Chat.RoomInventory do
  @moduledoc """
  Loads room and external channel binding metadata for the ChatOps console.
  """

  alias AgentJido.ContentOps.Messaging

  @type binding :: %{
          channel: String.t(),
          external_room_id: String.t() | nil,
          instance_id: String.t() | nil
        }

  @type room :: %{
          room_id: String.t(),
          room_name: String.t(),
          bindings: [binding()]
        }

  @doc """
  Returns room-to-channel binding inventory from the ContentOps messaging instance.
  """
  @spec fetch() :: {:ok, [room()]} | {:error, term()}
  def fetch do
    fetch(messaging: Messaging)
  end

  @doc """
  Returns room-to-channel binding inventory using the given messaging module.
  """
  @spec fetch(keyword()) :: {:ok, [room()]} | {:error, term()}
  def fetch(opts) when is_list(opts) do
    messaging = Keyword.get(opts, :messaging, Messaging)

    if runtime_available?(messaging) do
      with {:ok, rooms} <- safe_messaging_call(fn -> messaging.list_rooms(limit: 500) end) do
        {:ok,
         rooms
         |> Enum.map(&build_room(&1, messaging))
         |> Enum.reject(&is_nil/1)
         |> Enum.sort_by(& &1.room_id)}
      else
        {:error, :messaging_unavailable} -> {:ok, []}
        {:error, reason} -> {:error, reason}
      end
    else
      {:ok, []}
    end
  end

  defp build_room(%{id: room_id} = room, messaging) when is_binary(room_id) do
    %{
      room_id: room_id,
      room_name: normalize_string(Map.get(room, :name), room_id),
      bindings: load_bindings(messaging, room_id)
    }
  end

  defp build_room(_room, _messaging), do: nil

  defp load_bindings(messaging, room_id) do
    case safe_messaging_call(fn -> messaging.list_room_bindings(room_id) end) do
      {:ok, bindings} when is_list(bindings) ->
        bindings
        |> Enum.map(&normalize_binding/1)
        |> Enum.reject(&is_nil/1)
        |> Enum.sort_by(&binding_sort_key/1)

      _ ->
        []
    end
  end

  defp normalize_binding(binding) when is_map(binding) do
    %{
      channel: normalize_channel(Map.get(binding, :channel)),
      external_room_id: normalize_optional(Map.get(binding, :external_room_id)),
      instance_id: normalize_optional(Map.get(binding, :instance_id))
    }
  end

  defp normalize_binding(_binding), do: nil

  defp binding_sort_key(binding) do
    {binding.channel || "", binding.external_room_id || "", binding.instance_id || ""}
  end

  defp normalize_channel(channel) when is_atom(channel), do: channel |> Atom.to_string() |> normalize_string("unknown")
  defp normalize_channel(channel) when is_binary(channel), do: normalize_string(channel, "unknown")
  defp normalize_channel(channel), do: channel |> to_string() |> normalize_string("unknown")

  defp normalize_optional(value), do: normalize_string(value, nil)

  defp normalize_string(nil, default), do: default

  defp normalize_string(value, default) when is_binary(value) do
    value
    |> String.trim()
    |> case do
      "" -> default
      normalized -> normalized
    end
  end

  defp normalize_string(value, default), do: value |> to_string() |> normalize_string(default)

  defp runtime_available?(messaging) do
    function_exported?(messaging, :__jido_messaging__, 1) and
      messaging
      |> runtime_name()
      |> runtime_running?()
  rescue
    _ -> false
  end

  defp runtime_name(messaging), do: messaging.__jido_messaging__(:runtime)
  defp runtime_running?(runtime) when is_atom(runtime), do: not is_nil(Process.whereis(runtime))
  defp runtime_running?(_runtime), do: false

  defp safe_messaging_call(fun) when is_function(fun, 0) do
    fun.()
  rescue
    error ->
      {:error, {:messaging_exception, Exception.message(error)}}
  catch
    :exit, {:noproc, _details} ->
      {:error, :messaging_unavailable}

    :exit, {:normal, _details} ->
      {:error, :messaging_unavailable}

    :exit, reason ->
      {:error, {:messaging_exit, reason}}
  end
end
