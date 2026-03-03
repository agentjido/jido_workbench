defmodule AgentJidoWeb.Plugs.LegacyEcosystemRouteRedirect do
  @moduledoc """
  Redirects legacy ecosystem routes to canonical destinations with HTTP 301.
  """
  import Plug.Conn

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%Plug.Conn{method: method, request_path: "/ecosystem/package-matrix"} = conn, _opts)
      when method in ["GET", "HEAD"] do
    destination = "/ecosystem/matrix" <> query_suffix(conn.query_string)

    conn
    |> put_resp_header("location", destination)
    |> send_resp(301, "")
    |> halt()
  end

  def call(conn, _opts), do: conn

  defp query_suffix(""), do: ""
  defp query_suffix(query_string) when is_binary(query_string), do: "?" <> query_string
end
