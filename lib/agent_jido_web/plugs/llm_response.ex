defmodule AgentJidoWeb.Plugs.LLMResponse do
  @moduledoc """
  Adds LLM discovery headers and serves markdown responses for supported
  public routes when clients request `Accept: text/markdown`.
  """
  import Plug.Conn

  alias AgentJidoWeb.MarkdownContent
  alias AgentJidoWeb.MarkdownLinks

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%Plug.Conn{method: method, request_path: path} = conn, _opts)
      when method in ["GET", "HEAD"] and is_binary(path) do
    if MarkdownContent.eligible_public_path?(path) do
      absolute_url = MarkdownLinks.absolute_url(path, conn.query_string)

      cond do
        method == "GET" and markdown_request?(conn) ->
          maybe_render_markdown(conn, path, absolute_url)

        true ->
          register_discovery_headers(conn, absolute_url)
      end
    else
      conn
    end
  end

  def call(conn, _opts), do: conn

  defp maybe_render_markdown(conn, path, absolute_url) do
    case MarkdownContent.resolve(path, absolute_url) do
      {:ok, markdown} ->
        conn
        |> put_discovery_headers(absolute_url)
        |> put_resp_content_type("text/markdown", "utf-8")
        |> send_resp(200, markdown)
        |> halt()

      :no_match ->
        register_discovery_headers(conn, absolute_url)
    end
  end

  defp register_discovery_headers(conn, absolute_url) do
    register_before_send(conn, fn conn ->
      put_discovery_headers(conn, absolute_url)
    end)
  end

  defp put_discovery_headers(conn, absolute_url) do
    conn
    |> put_vary_accept()
    |> put_link_header(absolute_url)
  end

  defp put_vary_accept(conn) do
    existing =
      conn
      |> get_resp_header("vary")
      |> List.first()
      |> parse_comma_separated_values()

    has_accept? =
      Enum.any?(existing, fn value -> String.downcase(value) == "accept" end)

    values = if has_accept?, do: existing, else: existing ++ ["Accept"]

    put_resp_header(conn, "vary", Enum.join(values, ", "))
  end

  defp put_link_header(conn, absolute_url) do
    existing =
      conn
      |> get_resp_header("link")
      |> Enum.flat_map(&parse_comma_separated_values/1)

    desired = [
      "</llms.txt>; rel=\"alternate\"; type=\"text/plain\"",
      "<#{absolute_url}>; rel=\"alternate\"; type=\"text/markdown\""
    ]

    merged =
      (existing ++ desired)
      |> Enum.reject(&(&1 == ""))
      |> Enum.uniq()
      |> Enum.join(", ")

    put_resp_header(conn, "link", merged)
  end

  defp markdown_request?(conn) do
    conn
    |> get_req_header("accept")
    |> Enum.any?(fn accept -> String.contains?(String.downcase(accept), "text/markdown") end)
  end

  defp parse_comma_separated_values(nil), do: []
  defp parse_comma_separated_values(""), do: []

  defp parse_comma_separated_values(value) when is_binary(value) do
    value
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
