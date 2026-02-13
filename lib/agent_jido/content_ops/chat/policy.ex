defmodule AgentJido.ContentOps.Chat.Policy do
  @moduledoc """
  Authorization and feature-gate policy checks for chat mutation tools.
  """

  alias AgentJido.ContentOps.Chat.{Authorizer, Config}

  defmodule UnauthorizedError do
    defexception message: "mutation not authorized"
  end

  defmodule MutationsDisabledError do
    defexception message: "mutation tools are disabled"
  end

  @type actor :: %{channel: atom() | nil, external_user_id: String.t()}

  @doc "Normalize actor from tool context."
  @spec actor_from_tool_context(map()) :: actor()
  def actor_from_tool_context(context) when is_map(context) do
    actor = Map.get(context, :actor, Map.get(context, "actor", %{}))

    cond do
      is_map(actor) and map_size(actor) > 0 ->
        %{
          channel: normalize_channel(Map.get(actor, :channel, Map.get(actor, "channel"))),
          external_user_id: normalize_id(Map.get(actor, :external_user_id, Map.get(actor, "external_user_id")))
        }

      true ->
        %{channel: nil, external_user_id: ""}
    end
  end

  def actor_from_tool_context(_), do: %{channel: nil, external_user_id: ""}

  @doc "Returns :ok if actor is authorized to mutate."
  @spec authorize_mutation(actor()) :: :ok | {:error, :mutations_disabled | :unauthorized}
  def authorize_mutation(actor) do
    cfg = Config.load!()

    cond do
      cfg.mutation_tools_enabled != true ->
        {:error, :mutations_disabled}

      Authorizer.allowed_to_mutate?(actor) ->
        :ok

      true ->
        {:error, :unauthorized}
    end
  end

  @doc "Raises if actor is unauthorized or mutation tools are disabled."
  @spec authorize_mutation!(actor()) :: :ok
  def authorize_mutation!(actor) do
    case authorize_mutation(actor) do
      :ok ->
        :ok

      {:error, :mutations_disabled} ->
        raise MutationsDisabledError

      {:error, :unauthorized} ->
        raise UnauthorizedError
    end
  end

  defp normalize_channel(:telegram), do: :telegram
  defp normalize_channel(:discord), do: :discord
  defp normalize_channel("telegram"), do: :telegram
  defp normalize_channel("discord"), do: :discord
  defp normalize_channel(_), do: nil

  defp normalize_id(nil), do: ""
  defp normalize_id(id) when is_binary(id), do: String.trim(id)
  defp normalize_id(id), do: to_string(id)
end
