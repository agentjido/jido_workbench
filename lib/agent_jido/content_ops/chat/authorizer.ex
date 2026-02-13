defmodule AgentJido.ContentOps.Chat.Authorizer do
  @moduledoc """
  Authorization checks for mutating chat commands.
  """

  alias AgentJido.ContentOps.Chat.Config

  @doc "Returns true if the actor can execute mutating operations."
  @spec allowed_to_mutate?(map()) :: boolean()
  def allowed_to_mutate?(%{channel: channel, external_user_id: external_user_id}) do
    cfg = Config.load!()
    channel = normalize_channel(channel)
    external_user_id = normalize_id(external_user_id)

    if external_user_id == "" do
      false
    else
      case channel do
        :telegram -> MapSet.member?(cfg.allowed_telegram_user_ids, external_user_id)
        :discord -> MapSet.member?(cfg.allowed_discord_user_ids, external_user_id)
        _other -> false
      end
    end
  end

  def allowed_to_mutate?(_), do: false

  @doc "Extracts actor identity from the channel callback context."
  @spec actor_from_context(map()) :: %{channel: atom() | nil, external_user_id: String.t()}
  def actor_from_context(context) do
    channel = context |> Map.get(:channel) |> normalize_channel()

    external_ids =
      context
      |> Map.get(:participant, %{})
      |> Map.get(:external_ids, %{})

    external_user_id =
      (Map.get(external_ids, channel) || Map.get(external_ids, to_string(channel)))
      |> normalize_id()

    %{channel: channel, external_user_id: external_user_id}
  end

  defp normalize_channel(nil), do: nil
  defp normalize_channel("telegram"), do: :telegram
  defp normalize_channel("discord"), do: :discord
  defp normalize_channel(:telegram), do: :telegram
  defp normalize_channel(:discord), do: :discord

  defp normalize_channel(module) when is_atom(module) do
    cond do
      Code.ensure_loaded?(module) and function_exported?(module, :channel_type, 0) ->
        normalize_channel(module.channel_type())

      true ->
        nil
    end
  end

  defp normalize_channel(_), do: nil

  defp normalize_id(nil), do: ""
  defp normalize_id(id) when is_binary(id), do: String.trim(id)
  defp normalize_id(id), do: to_string(id)
end
