defmodule AgentJido.ContentOps.Chat.ActionTimeline do
  @moduledoc """
  Builds merged action/run timeline entries for the ChatOps console.
  """

  alias AgentJido.ContentOps.Chat.{ActionStore, RunStore}

  @default_limit 30

  @type outcome :: :accepted | :succeeded | :blocked | :failed | :unknown
  @type authz_status :: :authorized | :unauthorized | :mutations_disabled | :unknown | nil

  @type entry :: %{
          id: String.t(),
          timestamp: DateTime.t() | nil,
          type: :action | :run,
          label: String.t(),
          outcome: outcome(),
          authz_status: authz_status(),
          mutation_enabled: boolean() | nil,
          actor: %{channel: String.t() | nil, external_user_id: String.t()} | nil,
          details: String.t() | nil,
          reason: atom() | String.t() | nil
        }

  @doc "Returns merged timeline entries."
  @spec fetch() :: {:ok, [entry()]}
  def fetch do
    fetch([])
  end

  @doc """
  Returns merged timeline entries.

  ## Options
  - `:limit` - Max entries returned (defaults to 30)
  - `:run_store` - Run store module (defaults to `AgentJido.ContentOps.Chat.RunStore`)
  - `:action_store` - Action store module (defaults to `AgentJido.ContentOps.Chat.ActionStore`)
  """
  @spec fetch(keyword()) :: {:ok, [entry()]}
  def fetch(opts) when is_list(opts) do
    limit = normalize_limit(Keyword.get(opts, :limit, @default_limit), @default_limit)
    run_store = Keyword.get(opts, :run_store, RunStore)
    action_store = Keyword.get(opts, :action_store, ActionStore)

    entries =
      fetch_run_entries(run_store, limit) ++ fetch_action_entries(action_store, limit)

    timeline =
      entries
      |> Enum.sort_by(&timeline_sort_key/1, :desc)
      |> Enum.take(limit)

    {:ok, timeline}
  end

  @doc "Returns merged timeline entries."
  @spec fetch_action_timeline() :: {:ok, [entry()]}
  def fetch_action_timeline do
    fetch()
  end

  @doc "Returns merged timeline entries."
  @spec fetch_action_timeline(keyword()) :: {:ok, [entry()]}
  def fetch_action_timeline(opts) when is_list(opts) do
    fetch(opts)
  end

  defp fetch_run_entries(run_store, limit) do
    run_store
    |> safe_recent(limit)
    |> Enum.map(&normalize_run_entry/1)
    |> Enum.reject(&is_nil/1)
  end

  defp fetch_action_entries(action_store, limit) do
    action_store
    |> safe_recent(limit)
    |> Enum.map(&normalize_action_entry/1)
    |> Enum.reject(&is_nil/1)
  end

  defp safe_recent(module, limit) when is_atom(module) do
    cond do
      function_exported?(module, :recent, 1) ->
        module.recent(limit)

      function_exported?(module, :recent, 0) ->
        module.recent()

      true ->
        []
    end
  rescue
    _error ->
      []
  catch
    :exit, _reason ->
      []
  end

  defp safe_recent(_module, _limit), do: []

  defp normalize_run_entry(report) when is_map(report) do
    mode = normalize_mode(value(report, :mode))
    run_id = normalize_string(value(report, :run_id), "n/a")
    changes = stat_value(report, :change_requests)
    delivered = stat_value(report, :delivered)

    %{
      id: "run:" <> run_id,
      timestamp: normalize_datetime(value(report, :completed_at)),
      type: :run,
      label: "ContentOps #{mode} run completed",
      outcome: :succeeded,
      authz_status: nil,
      mutation_enabled: nil,
      actor: nil,
      details: "run_id #{run_id} · changes #{changes} · delivered #{delivered}",
      reason: nil
    }
  end

  defp normalize_run_entry(_report), do: nil

  defp normalize_action_entry(event) when is_map(event) do
    mode = normalize_mode(value(event, :mode))
    outcome = normalize_outcome(value(event, :outcome))
    authz_status = normalize_authz_status(value(event, :authz_status))

    label =
      normalize_string(
        value(event, :label),
        build_action_label(value(event, :action), mode, outcome)
      )

    %{
      id: normalize_string(value(event, :id), generate_event_id()),
      timestamp: normalize_datetime(value(event, :timestamp)),
      type: :action,
      label: label,
      outcome: outcome,
      authz_status: authz_status,
      mutation_enabled: normalize_boolean(value(event, :mutation_enabled)),
      actor: normalize_actor(value(event, :actor)),
      details: normalize_string(value(event, :message), nil),
      reason: value(event, :reason)
    }
  end

  defp normalize_action_entry(_event), do: nil

  defp stat_value(report, key) do
    report
    |> value(:stats)
    |> normalize_stats()
    |> Map.get(key, 0)
  end

  defp normalize_stats(stats) when is_map(stats) do
    %{
      change_requests: normalize_integer(value(stats, :change_requests), 0),
      delivered: normalize_integer(value(stats, :delivered), 0)
    }
  end

  defp normalize_stats(_stats), do: %{change_requests: 0, delivered: 0}

  defp normalize_actor(actor) when is_map(actor) do
    %{
      channel: normalize_string(value(actor, :channel), nil),
      external_user_id: normalize_string(value(actor, :external_user_id), "")
    }
  end

  defp normalize_actor(_actor), do: nil

  defp normalize_mode(mode) when is_atom(mode), do: Atom.to_string(mode)

  defp normalize_mode(mode) when is_binary(mode) do
    normalize_string(mode, "unknown")
  end

  defp normalize_mode(_mode), do: "unknown"

  defp normalize_outcome(:accepted), do: :accepted
  defp normalize_outcome(:succeeded), do: :succeeded
  defp normalize_outcome(:blocked), do: :blocked
  defp normalize_outcome(:failed), do: :failed
  defp normalize_outcome("accepted"), do: :accepted
  defp normalize_outcome("succeeded"), do: :succeeded
  defp normalize_outcome("blocked"), do: :blocked
  defp normalize_outcome("failed"), do: :failed
  defp normalize_outcome(_outcome), do: :unknown

  defp normalize_authz_status(:authorized), do: :authorized
  defp normalize_authz_status(:unauthorized), do: :unauthorized
  defp normalize_authz_status(:mutations_disabled), do: :mutations_disabled
  defp normalize_authz_status("authorized"), do: :authorized
  defp normalize_authz_status("unauthorized"), do: :unauthorized
  defp normalize_authz_status("mutations_disabled"), do: :mutations_disabled
  defp normalize_authz_status(nil), do: nil
  defp normalize_authz_status(_status), do: :unknown

  defp normalize_boolean(true), do: true
  defp normalize_boolean(false), do: false
  defp normalize_boolean(_value), do: nil

  defp normalize_datetime(%DateTime{} = value), do: value

  defp normalize_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, parsed, _offset} -> parsed
      _other -> nil
    end
  end

  defp normalize_datetime(_value), do: nil

  defp normalize_integer(value, _default) when is_integer(value), do: value

  defp normalize_integer(value, default) when is_binary(value) do
    case Integer.parse(String.trim(value)) do
      {parsed, ""} -> parsed
      _other -> default
    end
  end

  defp normalize_integer(_value, default), do: default

  defp normalize_limit(value, _default) when is_integer(value) and value > 0, do: value
  defp normalize_limit(_value, default), do: default

  defp normalize_string(nil, default), do: default

  defp normalize_string(value, default) when is_binary(value) do
    case String.trim(value) do
      "" -> default
      normalized -> normalized
    end
  end

  defp normalize_string(value, default), do: value |> to_string() |> normalize_string(default)

  defp build_action_label(action, mode, _outcome) when action in [:run, "run"] do
    "Run #{mode} command"
  end

  defp build_action_label(action, _mode, _outcome) do
    "#{action || "action"} command"
  end

  defp timeline_sort_key(%{timestamp: %DateTime{} = timestamp}) do
    DateTime.to_unix(timestamp, :microsecond)
  end

  defp timeline_sort_key(_entry), do: -1

  defp value(map, key) when is_map(map) and is_atom(key) do
    if Map.has_key?(map, key) do
      Map.get(map, key)
    else
      Map.get(map, Atom.to_string(key))
    end
  end

  defp generate_event_id do
    "chatops_timeline_" <> Integer.to_string(System.unique_integer([:positive, :monotonic]))
  end
end
