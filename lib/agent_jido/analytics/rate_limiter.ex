defmodule AgentJido.Analytics.RateLimiter do
  @moduledoc """
  In-memory rate limiter keyed by visitor id + event name.
  """

  @table :agent_jido_analytics_rate_limiter
  @default_window_seconds 60
  @default_max_events 120

  @doc """
  Returns true when the event is allowed for the current rate-limit window.
  """
  @spec allow?(String.t(), String.t(), keyword()) :: boolean()
  def allow?(visitor_id, event, opts \\ [])

  def allow?(visitor_id, event, opts) when is_binary(visitor_id) and is_binary(event) do
    max_events = Keyword.get(opts, :max_events, @default_max_events)
    window_seconds = Keyword.get(opts, :window_seconds, @default_window_seconds)
    now = Keyword.get(opts, :now, System.system_time(:second))
    window_bucket = div(now, window_seconds)
    expires_at = (window_bucket + 1) * window_seconds
    key = {visitor_id, event, window_bucket}

    ensure_table!()

    count = :ets.update_counter(@table, key, {2, 1}, {key, 0, expires_at})

    maybe_cleanup(now)
    count <= max_events
  rescue
    _ -> true
  end

  def allow?(_visitor_id, _event, _opts), do: true

  @doc """
  Clears all limiter buckets. Primarily used in tests.
  """
  @spec reset!() :: :ok
  def reset! do
    ensure_table!()
    :ets.delete_all_objects(@table)
    :ok
  rescue
    _ -> :ok
  end

  defp ensure_table! do
    case :ets.whereis(@table) do
      :undefined ->
        :ets.new(@table, [
          :named_table,
          :set,
          :public,
          {:read_concurrency, true},
          {:write_concurrency, true}
        ])

      _tid ->
        :ok
    end
  rescue
    ArgumentError -> :ok
  end

  defp maybe_cleanup(now) do
    # Keep cleanup overhead low by sweeping roughly every 31 seconds.
    if rem(now, 31) == 0 do
      spec = [{{:_, :_, :"$1"}, [{:<, :"$1", now}], [true]}]
      :ets.select_delete(@table, spec)
    else
      :ok
    end
  rescue
    _ -> :ok
  end
end
