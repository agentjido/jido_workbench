defmodule AgentJido.ContentAssistant.PageResponseCache do
  @moduledoc """
  Bounded ETS cache for `/search` page responses.
  """

  use GenServer

  alias AgentJido.ContentAssistant.Response

  @table :content_assistant_page_response_cache
  @default_ttl_ms :timer.minutes(15)
  @default_gc_interval_ms :timer.minutes(1)
  @default_max_entries 1_000
  @telemetry_hit [:agent_jido, :content_assistant, :page_cache, :hit]
  @telemetry_miss [:agent_jido, :content_assistant, :page_cache, :miss]

  @type cache_key :: term()

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec get(cache_key()) :: {:ok, Response.t()} | :miss
  def get(key) do
    case :ets.lookup(@table, key) do
      [{^key, %Response{} = response, inserted_at_ms}] ->
        if fresh?(inserted_at_ms, ttl_ms()) do
          emit_telemetry(@telemetry_hit)
          {:ok, response}
        else
          :ets.delete(@table, key)
          emit_telemetry(@telemetry_miss)
          :miss
        end

      _ ->
        emit_telemetry(@telemetry_miss)
        :miss
    end
  rescue
    _ ->
      :miss
  end

  @spec put(cache_key(), Response.t()) :: :ok
  def put(key, %Response{} = response) do
    inserted_at_ms = System.monotonic_time(:millisecond)
    :ets.insert(@table, {key, response, inserted_at_ms})
    trim_to_limit(max_entries())
    :ok
  rescue
    _ ->
      :ok
  end

  @spec clear() :: :ok
  def clear do
    if :ets.whereis(@table) != :undefined do
      :ets.delete_all_objects(@table)
    end

    :ok
  end

  @impl true
  def init(_opts) do
    _table =
      :ets.new(@table, [:named_table, :public, :set, read_concurrency: true, write_concurrency: true])

    schedule_gc()
    {:ok, %{}}
  rescue
    ArgumentError ->
      schedule_gc()
      {:ok, %{}}
  end

  @impl true
  def handle_info(:gc, state) do
    purge_stale(ttl_ms())
    trim_to_limit(max_entries())
    schedule_gc()
    {:noreply, state}
  end

  defp purge_stale(:infinity), do: :ok

  defp purge_stale(ttl_ms) when is_integer(ttl_ms) and ttl_ms > 0 do
    now_ms = System.monotonic_time(:millisecond)

    @table
    |> :ets.tab2list()
    |> Enum.each(fn
      {key, _response, inserted_at_ms} when now_ms - inserted_at_ms > ttl_ms ->
        :ets.delete(@table, key)

      _ ->
        :ok
    end)
  end

  defp purge_stale(_ttl_ms), do: :ok

  defp trim_to_limit(limit) when is_integer(limit) and limit > 0 do
    size = :ets.info(@table, :size) || 0

    if size > limit do
      entries =
        @table
        |> :ets.tab2list()
        |> Enum.sort_by(fn {_key, _response, inserted_at_ms} -> inserted_at_ms end)

      drop_count = size - limit

      entries
      |> Enum.take(drop_count)
      |> Enum.each(fn {key, _response, _inserted_at_ms} ->
        :ets.delete(@table, key)
      end)
    end
  end

  defp trim_to_limit(_limit), do: :ok

  defp schedule_gc do
    Process.send_after(self(), :gc, gc_interval_ms())
  end

  defp fresh?(_inserted_at_ms, :infinity), do: true

  defp fresh?(inserted_at_ms, ttl_ms) when is_integer(inserted_at_ms) and is_integer(ttl_ms) and ttl_ms > 0 do
    System.monotonic_time(:millisecond) - inserted_at_ms <= ttl_ms
  end

  defp fresh?(_inserted_at_ms, _ttl_ms), do: false

  defp ttl_ms do
    case cfg_value(:page_response_cache_ttl_ms, @default_ttl_ms) do
      :infinity -> :infinity
      value when is_integer(value) and value > 0 -> value
      _ -> @default_ttl_ms
    end
  end

  defp gc_interval_ms do
    case cfg_value(:page_response_cache_gc_interval_ms, @default_gc_interval_ms) do
      value when is_integer(value) and value > 0 -> value
      _ -> @default_gc_interval_ms
    end
  end

  defp max_entries do
    case cfg_value(:page_response_cache_max_entries, @default_max_entries) do
      value when is_integer(value) and value > 0 -> value
      _ -> @default_max_entries
    end
  end

  defp cfg_value(key, default) do
    config = Application.get_env(:agent_jido, AgentJido.ContentAssistant, [])

    case config do
      cfg when is_list(cfg) -> Keyword.get(cfg, key, default)
      cfg when is_map(cfg) -> Map.get(cfg, key, default)
      _ -> default
    end
  end

  defp emit_telemetry(event) do
    :telemetry.execute(event, %{count: 1}, %{})
  rescue
    _ -> :ok
  end
end
