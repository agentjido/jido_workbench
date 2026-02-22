defmodule AgentJidoWeb.AnalyticsEventController do
  @moduledoc """
  First-party analytics event ingestion endpoint.
  """
  use AgentJidoWeb, :controller

  alias AgentJido.Analytics

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    event = read(params, "event")
    properties = read(params, "properties")

    attrs = build_attrs(conn, event, properties)

    case analytics_module().track_event(conn.assigns[:current_scope], attrs) do
      {:ok, _event} ->
        conn
        |> put_status(:accepted)
        |> json(%{ok: true})

      {:error, :rate_limited} ->
        conn
        |> put_status(:accepted)
        |> json(%{ok: true, rate_limited: true})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{ok: false, errors: translate_changeset_errors(changeset)})

      {:error, _reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{ok: false, error: "invalid_event"})
    end
  end

  defp build_attrs(conn, event, properties) do
    properties = normalize_properties(properties)
    identity = conn.assigns[:analytics_identity] || %{}

    metadata =
      properties
      |> read("metadata")
      |> normalize_properties()
      |> Map.merge(%{"referrer_host" => read(identity, "referrer_host")}, fn _key, left, _right -> left end)

    %{
      "event" => event,
      "source" => read(properties, "source"),
      "channel" => read(properties, "channel"),
      "path" => infer_path(conn, properties),
      "section_id" => read(properties, "section_id"),
      "target_url" => read(properties, "target_url"),
      "rank" => read(properties, "rank"),
      "feedback_value" => read(properties, "feedback_value"),
      "feedback_note" => read(properties, "feedback_note"),
      "query_log_id" => read(properties, "query_log_id"),
      "visitor_id" => read(identity, "visitor_id"),
      "session_id" => read(identity, "session_id"),
      "metadata" => metadata
    }
  end

  defp infer_path(conn, properties) do
    referer_path =
      case get_req_header(conn, "referer") do
        [referer | _] ->
          case URI.parse(referer).path do
            path when is_binary(path) -> path
            _ -> nil
          end

        _ ->
          nil
      end

    cond do
      is_binary(referer_path) and String.starts_with?(referer_path, "/") ->
        referer_path

      path = read(properties, "path") ->
        if is_binary(path) and String.starts_with?(path, "/"), do: path, else: "/"

      true ->
        "/"
    end
  end

  defp translate_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} -> message end)
  end

  defp normalize_properties(value) when is_map(value), do: stringify_keys(value)
  defp normalize_properties(_value), do: %{}

  defp stringify_keys(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      key =
        case key do
          atom when is_atom(atom) -> Atom.to_string(atom)
          binary when is_binary(binary) -> binary
          other -> to_string(other)
        end

      Map.put(acc, key, value)
    end)
  end

  defp read(map, key) when is_map(map) and is_binary(key) do
    Map.get(map, key) || Map.get(map, String.to_atom(key))
  rescue
    ArgumentError -> Map.get(map, key)
  end

  defp analytics_module do
    Application.get_env(:agent_jido, :analytics_module, Analytics)
  end
end
