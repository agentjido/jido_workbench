defmodule AgentJido.MCP do
  @moduledoc """
  Shared configuration and helper functions for the MCP server surfaces.
  """

  @default_protocol_version "2025-11-25"
  @default_http_max_body_bytes 32_768
  @default_http_rate_limit_max_requests 60
  @default_http_rate_limit_window_seconds 60
  @default_search_limit 10
  @max_search_limit 20
  @default_query_max_length 500

  @type config_opt ::
          {:protocol_version, String.t()}
          | {:http_max_body_bytes, pos_integer()}
          | {:http_rate_limit_max_requests, pos_integer()}
          | {:http_rate_limit_window_seconds, pos_integer()}
          | {:search_limit, pos_integer()}
          | {:query_max_length, pos_integer()}
          | {:server_name, String.t()}

  @spec config() :: keyword()
  def config do
    Application.get_env(:agent_jido, __MODULE__, [])
  end

  @spec protocol_version() :: String.t()
  def protocol_version do
    config()
    |> Keyword.get(:protocol_version, @default_protocol_version)
    |> normalize_string(@default_protocol_version)
  end

  @spec server_name() :: String.t()
  def server_name do
    config()
    |> Keyword.get(:server_name, "agent_jido_docs")
    |> normalize_string("agent_jido_docs")
  end

  @spec server_version() :: String.t()
  def server_version do
    :agent_jido
    |> Application.spec(:vsn)
    |> case do
      nil -> "0.0.0"
      version -> List.to_string(version)
    end
  end

  @spec http_max_body_bytes() :: pos_integer()
  def http_max_body_bytes do
    config()
    |> Keyword.get(:http_max_body_bytes, @default_http_max_body_bytes)
    |> normalize_positive_integer(@default_http_max_body_bytes)
  end

  @spec http_rate_limit_max_requests() :: pos_integer()
  def http_rate_limit_max_requests do
    config()
    |> Keyword.get(:http_rate_limit_max_requests, @default_http_rate_limit_max_requests)
    |> normalize_positive_integer(@default_http_rate_limit_max_requests)
  end

  @spec http_rate_limit_window_seconds() :: pos_integer()
  def http_rate_limit_window_seconds do
    config()
    |> Keyword.get(:http_rate_limit_window_seconds, @default_http_rate_limit_window_seconds)
    |> normalize_positive_integer(@default_http_rate_limit_window_seconds)
  end

  @spec default_search_limit() :: pos_integer()
  def default_search_limit do
    config()
    |> Keyword.get(:search_limit, @default_search_limit)
    |> normalize_positive_integer(@default_search_limit)
  end

  @spec max_search_limit() :: pos_integer()
  def max_search_limit, do: @max_search_limit

  @spec query_max_length() :: pos_integer()
  def query_max_length do
    config()
    |> Keyword.get(:query_max_length, @default_query_max_length)
    |> normalize_positive_integer(@default_query_max_length)
  end

  @spec endpoint_url() :: String.t()
  def endpoint_url do
    AgentJidoWeb.Endpoint.url()
    |> String.trim_trailing("/")
  end

  @spec canonical_url(String.t()) :: String.t()
  def canonical_url(path) when is_binary(path), do: endpoint_url() <> path

  defp normalize_positive_integer(value, _default) when is_integer(value) and value > 0, do: value
  defp normalize_positive_integer(_value, default), do: default

  defp normalize_string(value, _default) when is_binary(value) and value != "", do: value
  defp normalize_string(_value, default), do: default
end
