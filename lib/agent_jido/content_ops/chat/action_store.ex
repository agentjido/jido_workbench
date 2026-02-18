defmodule AgentJido.ContentOps.Chat.ActionStore do
  @moduledoc """
  In-memory cache of recent ChatOps action attempts.
  """

  use GenServer

  @default_max_events 100

  @type event :: map()

  @doc "Starts the action store process."
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc "Returns recent action events (newest first)."
  @spec recent(non_neg_integer()) :: [event()]
  def recent(limit \\ 20) when is_integer(limit) and limit >= 0 do
    GenServer.call(__MODULE__, {:recent, limit})
  end

  @doc "Records a new action event."
  @spec record(event()) :: :ok
  def record(event) when is_map(event) do
    GenServer.cast(__MODULE__, {:record, event})
  end

  @doc "Clears all action events."
  @spec clear() :: :ok
  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  @impl true
  def init(opts) do
    {:ok,
     %{
       events: [],
       max_events: Keyword.get(opts, :max_events, @default_max_events)
     }}
  end

  @impl true
  def handle_call({:recent, limit}, _from, state) do
    {:reply, Enum.take(state.events, limit), state}
  end

  @impl true
  def handle_cast({:record, event}, state) do
    normalized = normalize_event(event)

    events =
      [normalized | state.events]
      |> Enum.take(state.max_events)

    {:noreply, %{state | events: events}}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | events: []}}
  end

  defp normalize_event(event) when is_map(event) do
    %{
      id: normalize_string(event_value(event, :id), generate_event_id()),
      timestamp: normalize_datetime(event_value(event, :timestamp)) || DateTime.utc_now(),
      action: event_value(event, :action),
      mode: event_value(event, :mode),
      outcome: event_value(event, :outcome),
      authz_status: event_value(event, :authz_status),
      mutation_enabled: normalize_boolean(event_value(event, :mutation_enabled)),
      reason: event_value(event, :reason),
      label: normalize_string(event_value(event, :label), nil),
      message: normalize_string(event_value(event, :message), nil),
      source: event_value(event, :source),
      actor: normalize_actor(event_value(event, :actor))
    }
  end

  defp event_value(event, key) when is_atom(key) do
    if Map.has_key?(event, key) do
      Map.get(event, key)
    else
      Map.get(event, Atom.to_string(key))
    end
  end

  defp normalize_datetime(%DateTime{} = value), do: value

  defp normalize_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, parsed, _offset} -> parsed
      _other -> nil
    end
  end

  defp normalize_datetime(_value), do: nil

  defp normalize_actor(actor) when is_map(actor) do
    %{
      channel: normalize_string(event_value(actor, :channel), nil),
      external_user_id: normalize_string(event_value(actor, :external_user_id), "")
    }
  end

  defp normalize_actor(_actor), do: nil

  defp normalize_boolean(true), do: true
  defp normalize_boolean(false), do: false
  defp normalize_boolean(_value), do: nil

  defp normalize_string(nil, default), do: default

  defp normalize_string(value, default) when is_binary(value) do
    case String.trim(value) do
      "" -> default
      normalized -> normalized
    end
  end

  defp normalize_string(value, default), do: value |> to_string() |> normalize_string(default)

  defp generate_event_id do
    "chatops_action_" <> Integer.to_string(System.unique_integer([:positive, :monotonic]))
  end
end
