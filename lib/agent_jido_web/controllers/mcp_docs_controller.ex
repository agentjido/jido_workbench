defmodule AgentJidoWeb.MCPDocsController do
  @moduledoc """
  Public HTTP transport for the read-only docs MCP server.
  """

  use AgentJidoWeb, :controller

  alias AgentJido.Analytics.RateLimiter
  alias AgentJido.MCP
  alias AgentJido.MCP.Server

  @invalid_request_code -32_600
  @rate_limited_code -32_029
  @request_too_large_code -32_413

  @spec handle(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def handle(%Plug.Conn{method: "POST"} = conn, params) when is_map(params) do
    request_id = Map.get(params, "id")

    with :ok <- validate_body_size(conn, params),
         :ok <- enforce_rate_limit(conn) do
      conn =
        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("mcp-protocol-version", MCP.protocol_version())

      case Server.handle_http_message(params, tool_opts: tool_opts()) do
        {:reply, response} ->
          conn
          |> put_status(:ok)
          |> json(response)

        :noreply ->
          send_resp(conn, :accepted, "")
      end
    else
      {:error, :too_large} ->
        conn
        |> put_status(:payload_too_large)
        |> put_resp_content_type("application/json")
        |> json(error_response(request_id, @request_too_large_code, "Request body exceeds the MCP HTTP limit"))

      {:error, :rate_limited} ->
        conn
        |> put_status(:too_many_requests)
        |> put_resp_content_type("application/json")
        |> json(error_response(request_id, @rate_limited_code, "Rate limit exceeded"))
    end
  end

  def handle(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(:method_not_allowed)
    |> json(error_response(nil, @invalid_request_code, "Only POST is supported for this endpoint"))
  end

  defp validate_body_size(conn, params) do
    max_body_bytes = MCP.http_max_body_bytes()

    size =
      conn
      |> get_req_header("content-length")
      |> List.first()
      |> case do
        nil ->
          params
          |> Jason.encode!()
          |> byte_size()

        value ->
          case Integer.parse(value) do
            {parsed, ""} -> parsed
            _other -> max_body_bytes + 1
          end
      end

    if size <= max_body_bytes, do: :ok, else: {:error, :too_large}
  end

  defp enforce_rate_limit(conn) do
    if RateLimiter.allow?(
         client_identifier(conn),
         "mcp_docs_http",
         max_events: MCP.http_rate_limit_max_requests(),
         window_seconds: MCP.http_rate_limit_window_seconds()
       ) do
      :ok
    else
      {:error, :rate_limited}
    end
  end

  defp client_identifier(conn) do
    forwarded_for =
      conn
      |> get_req_header("x-forwarded-for")
      |> List.first()
      |> parse_forwarded_for()

    real_ip =
      conn
      |> get_req_header("x-real-ip")
      |> List.first()
      |> normalize_ip_string()

    cond do
      is_binary(forwarded_for) -> forwarded_for
      is_binary(real_ip) -> real_ip
      true -> tuple_ip_to_string(conn.remote_ip)
    end
  end

  defp parse_forwarded_for(nil), do: nil

  defp parse_forwarded_for(value) do
    value
    |> String.split(",", trim: true)
    |> Enum.map(&normalize_ip_string/1)
    |> Enum.find(&is_binary/1)
  end

  defp normalize_ip_string(value) when is_binary(value) do
    value
    |> String.trim()
    |> case do
      "" ->
        nil

      candidate ->
        case :inet.parse_address(String.to_charlist(candidate)) do
          {:ok, _ip} -> candidate
          {:error, _reason} -> nil
        end
    end
  end

  defp normalize_ip_string(_value), do: nil

  defp tuple_ip_to_string({_, _, _, _} = ip), do: ip |> Tuple.to_list() |> Enum.join(".")
  defp tuple_ip_to_string({_, _, _, _, _, _, _, _} = ip), do: ip |> :inet.ntoa() |> to_string()

  defp error_response(id, code, message) do
    %{
      "jsonrpc" => "2.0",
      "id" => id,
      "error" => %{
        "code" => code,
        "message" => message
      }
    }
  end

  defp tool_opts do
    MCP.config()
    |> Keyword.get(:tool_opts, [])
  end
end
