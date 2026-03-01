defmodule AgentJido.Site do
  @moduledoc """
  Site URL and hostname helpers derived from runtime config.
  """

  @localhost_hosts ["localhost", "127.0.0.1"]

  @doc """
  Returns the canonical host for the site.
  """
  @spec canonical_host() :: String.t()
  def canonical_host do
    configured_host() || endpoint_host() || "localhost"
  end

  @doc """
  Returns the host configured on the endpoint URL.
  """
  @spec endpoint_host() :: String.t() | nil
  def endpoint_host do
    case URI.parse(AgentJidoWeb.Endpoint.url()) do
      %URI{host: host} when is_binary(host) and host != "" -> String.downcase(host)
      _ -> nil
    end
  end

  @doc """
  Returns hosts treated as first-party/internal.
  """
  @spec internal_hosts() :: [String.t()]
  def internal_hosts do
    host = canonical_host()

    [host, "www." <> host | @localhost_hosts]
    |> Enum.uniq()
  end

  defp configured_host do
    case Application.get_env(:agent_jido, :canonical_host) do
      host when is_binary(host) ->
        host
        |> String.trim()
        |> String.downcase()
        |> case do
          "" -> nil
          normalized -> normalized
        end

      _ ->
        nil
    end
  end
end
