defmodule AgentJido.ContentOps.Chat.Config do
  @moduledoc """
  Runtime configuration loader for the ContentOps chat subsystem.
  """

  @type binding :: %{
          room_id: String.t(),
          room_name: String.t(),
          telegram_chat_id: String.t(),
          discord_channel_id: String.t()
        }

  @type t :: %{
          enabled: boolean(),
          bindings: [binding()],
          allowed_telegram_user_ids: MapSet.t(String.t()),
          allowed_discord_user_ids: MapSet.t(String.t()),
          bot_name: String.t(),
          command_prefix: String.t(),
          github_owner: String.t(),
          github_repo: String.t(),
          github_labels_base: [String.t()],
          github_labels_docs_note: [String.t()],
          mutation_tools_enabled: boolean()
        }

  @defaults %{
    enabled: false,
    bindings: [],
    allowed_telegram_user_ids: [],
    allowed_discord_user_ids: [],
    bot_name: "ContentOps",
    command_prefix: "/ops",
    github_owner: "agentjido",
    github_repo: "agentjido_xyz",
    github_labels_base: ["contentops", "chatops"],
    github_labels_docs_note: ["docs-note"],
    mutation_tools_enabled: false
  }

  @doc "Loads and validates ContentOps chat configuration."
  @spec load!() :: t()
  def load! do
    raw =
      :agent_jido
      |> Application.get_env(AgentJido.ContentOps.Chat, [])
      |> normalize_map()

    enabled = Map.get(raw, :enabled, @defaults.enabled)
    bindings = raw |> Map.get(:bindings, @defaults.bindings) |> normalize_bindings!()

    allowed_telegram_user_ids =
      raw
      |> Map.get(:allowed_telegram_user_ids, @defaults.allowed_telegram_user_ids)
      |> normalize_user_ids()

    allowed_discord_user_ids =
      raw
      |> Map.get(:allowed_discord_user_ids, @defaults.allowed_discord_user_ids)
      |> normalize_user_ids()

    bot_name =
      raw
      |> Map.get(:bot_name, @defaults.bot_name)
      |> normalize_string(@defaults.bot_name)

    command_prefix =
      raw
      |> Map.get(:command_prefix, @defaults.command_prefix)
      |> normalize_command_prefix(@defaults.command_prefix)

    github_owner =
      raw
      |> Map.get(:github_owner, @defaults.github_owner)
      |> normalize_string(@defaults.github_owner)

    github_repo =
      raw
      |> Map.get(:github_repo, @defaults.github_repo)
      |> normalize_string(@defaults.github_repo)

    github_labels_base =
      raw
      |> Map.get(:github_labels_base, @defaults.github_labels_base)
      |> normalize_string_list(@defaults.github_labels_base)

    github_labels_docs_note =
      raw
      |> Map.get(:github_labels_docs_note, @defaults.github_labels_docs_note)
      |> normalize_string_list(@defaults.github_labels_docs_note)

    mutation_tools_enabled = Map.get(raw, :mutation_tools_enabled, @defaults.mutation_tools_enabled)

    %{
      enabled: enabled == true,
      bindings: bindings,
      allowed_telegram_user_ids: allowed_telegram_user_ids,
      allowed_discord_user_ids: allowed_discord_user_ids,
      bot_name: bot_name,
      command_prefix: command_prefix,
      github_owner: github_owner,
      github_repo: github_repo,
      github_labels_base: github_labels_base,
      github_labels_docs_note: github_labels_docs_note,
      mutation_tools_enabled: mutation_tools_enabled == true
    }
  end

  @doc "Returns only configured room IDs."
  @spec room_ids() :: [String.t()]
  def room_ids do
    load!()
    |> Map.fetch!(:bindings)
    |> Enum.map(& &1.room_id)
  end

  @doc "Returns whether chat integration is enabled."
  @spec enabled?() :: boolean()
  def enabled? do
    load!().enabled
  end

  defp normalize_map(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {k, v}, acc ->
      Map.put(acc, normalize_key(k), v)
    end)
  end

  defp normalize_map(value) when is_list(value) do
    value
    |> Enum.into(%{})
    |> normalize_map()
  end

  defp normalize_map(_), do: %{}

  defp normalize_key(key) when is_atom(key), do: key

  defp normalize_key("enabled"), do: :enabled
  defp normalize_key("bindings"), do: :bindings
  defp normalize_key("allowed_telegram_user_ids"), do: :allowed_telegram_user_ids
  defp normalize_key("allowed_discord_user_ids"), do: :allowed_discord_user_ids
  defp normalize_key("bot_name"), do: :bot_name
  defp normalize_key("command_prefix"), do: :command_prefix
  defp normalize_key("github_owner"), do: :github_owner
  defp normalize_key("github_repo"), do: :github_repo
  defp normalize_key("github_labels_base"), do: :github_labels_base
  defp normalize_key("github_labels_docs_note"), do: :github_labels_docs_note
  defp normalize_key("mutation_tools_enabled"), do: :mutation_tools_enabled
  defp normalize_key("room_id"), do: :room_id
  defp normalize_key("room_name"), do: :room_name
  defp normalize_key("telegram_chat_id"), do: :telegram_chat_id
  defp normalize_key("discord_channel_id"), do: :discord_channel_id
  defp normalize_key(key) when is_binary(key), do: key

  defp normalize_bindings!(bindings) when is_list(bindings) do
    normalized =
      Enum.map(bindings, fn binding ->
        map = normalize_map(binding)

        %{
          room_id: map |> Map.get(:room_id) |> required_string!(:room_id),
          room_name: map |> Map.get(:room_name, map[:room_id]) |> normalize_string(map[:room_id] || ""),
          telegram_chat_id:
            map
            |> Map.get(:telegram_chat_id)
            |> required_string!(:telegram_chat_id),
          discord_channel_id:
            map
            |> Map.get(:discord_channel_id)
            |> required_string!(:discord_channel_id)
        }
      end)

    room_ids = Enum.map(normalized, & &1.room_id)

    if length(room_ids) != length(Enum.uniq(room_ids)) do
      raise ArgumentError, "ContentOps chat bindings contain duplicate room_id values"
    end

    normalized
  end

  defp normalize_bindings!(_other), do: []

  defp required_string!(value, field) do
    value = normalize_string(value, nil)

    if is_nil(value) or value == "" do
      raise ArgumentError, "Missing required ContentOps chat binding field: #{field}"
    end

    value
  end

  defp normalize_string(nil, default), do: default
  defp normalize_string("", default), do: default
  defp normalize_string(value, _default) when is_binary(value), do: String.trim(value)
  defp normalize_string(value, _default), do: to_string(value)

  defp normalize_command_prefix(value, default) do
    value = normalize_string(value, default)

    if String.starts_with?(value, "/") do
      value
    else
      "/" <> value
    end
  end

  defp normalize_user_ids(%MapSet{} = ids), do: ids

  defp normalize_user_ids(ids) when is_list(ids) do
    ids
    |> Enum.map(&normalize_string(&1, ""))
    |> Enum.reject(&(&1 == ""))
    |> MapSet.new()
  end

  defp normalize_user_ids(ids) when is_binary(ids) do
    ids
    |> String.split(",", trim: true)
    |> normalize_user_ids()
  end

  defp normalize_user_ids(_), do: MapSet.new()

  defp normalize_string_list(nil, default), do: default
  defp normalize_string_list(values, _default) when is_list(values), do: normalize_list(values)
  defp normalize_string_list(values, default) when is_binary(values), do: values |> String.split(",", trim: true) |> normalize_list(default)
  defp normalize_string_list(_other, default), do: default

  defp normalize_list(values, _default \\ []) do
    values
    |> Enum.map(&normalize_string(&1, ""))
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end
end
