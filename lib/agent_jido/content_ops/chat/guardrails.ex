defmodule AgentJido.ContentOps.Chat.Guardrails do
  @moduledoc """
  Provides guardrail indicators for the ChatOps console.
  """

  alias AgentJido.ContentOps.Chat.{ActionStore, Config}

  @default_history_limit 30

  @type summary :: %{
          mutation_enabled: boolean(),
          latest_authz_status: :authorized | :unauthorized | :mutations_disabled | :unknown | nil,
          authz_counts: %{
            authorized: non_neg_integer(),
            unauthorized: non_neg_integer(),
            mutations_disabled: non_neg_integer(),
            unknown: non_neg_integer()
          },
          blocked_actions: non_neg_integer()
        }

  @doc "Returns guardrail summary values."
  @spec fetch() :: {:ok, summary()}
  def fetch do
    fetch([])
  end

  @doc """
  Returns guardrail summary values.

  ## Options
  - `:history_limit` - How many recent action events to analyze (defaults to 30)
  - `:action_store` - Action store module (defaults to `AgentJido.ContentOps.Chat.ActionStore`)
  - `:config_loader` - Config module (defaults to `AgentJido.ContentOps.Chat.Config`)
  """
  @spec fetch(keyword()) :: {:ok, summary()}
  def fetch(opts) when is_list(opts) do
    history_limit =
      normalize_limit(
        Keyword.get(opts, :history_limit, @default_history_limit),
        @default_history_limit
      )

    action_store = Keyword.get(opts, :action_store, ActionStore)
    config_loader = Keyword.get(opts, :config_loader, Config)

    events = safe_recent(action_store, history_limit)
    authz_statuses = Enum.map(events, &normalize_authz_status(value(&1, :authz_status)))
    latest_authz_status = Enum.find(authz_statuses, &(!is_nil(&1)))

    authz_counts =
      authz_statuses
      |> Enum.reject(&is_nil/1)
      |> Enum.frequencies()
      |> Map.merge(%{authorized: 0, unauthorized: 0, mutations_disabled: 0, unknown: 0}, fn _key, left, right ->
        left + right
      end)

    blocked_actions =
      Enum.count(events, fn event ->
        normalize_outcome(value(event, :outcome)) == :blocked
      end)

    {:ok,
     %{
       mutation_enabled: fetch_mutation_enabled(config_loader),
       latest_authz_status: latest_authz_status,
       authz_counts: authz_counts,
       blocked_actions: blocked_actions
     }}
  end

  @doc "Returns guardrail summary values."
  @spec fetch_guardrails() :: {:ok, summary()}
  def fetch_guardrails do
    fetch()
  end

  @doc "Returns guardrail summary values."
  @spec fetch_guardrails(keyword()) :: {:ok, summary()}
  def fetch_guardrails(opts) when is_list(opts) do
    fetch(opts)
  end

  defp fetch_mutation_enabled(config_loader) do
    cfg =
      if is_atom(config_loader) and function_exported?(config_loader, :load!, 0) do
        config_loader.load!()
      else
        %{}
      end

    Map.get(cfg, :mutation_tools_enabled) == true
  rescue
    _error ->
      false
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

  defp normalize_authz_status(:authorized), do: :authorized
  defp normalize_authz_status(:unauthorized), do: :unauthorized
  defp normalize_authz_status(:mutations_disabled), do: :mutations_disabled
  defp normalize_authz_status("authorized"), do: :authorized
  defp normalize_authz_status("unauthorized"), do: :unauthorized
  defp normalize_authz_status("mutations_disabled"), do: :mutations_disabled
  defp normalize_authz_status(nil), do: nil
  defp normalize_authz_status(_status), do: :unknown

  defp normalize_outcome(:blocked), do: :blocked
  defp normalize_outcome("blocked"), do: :blocked
  defp normalize_outcome(_status), do: :other

  defp normalize_limit(value, _default) when is_integer(value) and value > 0, do: value
  defp normalize_limit(_value, default), do: default

  defp value(map, key) when is_map(map) and is_atom(key) do
    if Map.has_key?(map, key) do
      Map.get(map, key)
    else
      Map.get(map, Atom.to_string(key))
    end
  end
end
