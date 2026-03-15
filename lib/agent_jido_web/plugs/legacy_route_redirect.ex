defmodule AgentJidoWeb.Plugs.LegacyRouteRedirect do
  @moduledoc """
  Performs fast, static legacy route redirects (301), including `.md` variants.
  """

  @behaviour Plug

  import Plug.Conn

  alias AgentJidoWeb.LegacyRedirects
  alias AgentJidoWeb.MarkdownLinks

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%Plug.Conn{method: method, request_path: request_path} = conn, _opts)
      when method in ["GET", "HEAD"] and is_binary(request_path) do
    case LegacyRedirects.destination(request_path) do
      destination_path when is_binary(destination_path) ->
        destination = destination_path <> query_suffix(conn.query_string)
        markdown_url = MarkdownLinks.absolute_url(MarkdownLinks.markdown_path(destination_path))

        conn
        |> put_resp_header("vary", "Accept")
        |> put_resp_header(
          "link",
          ~s(</llms.txt>; rel="alternate"; type="text/plain", <#{markdown_url}>; rel="alternate"; type="text/markdown")
        )
        |> put_resp_header("location", destination)
        |> send_resp(301, "")
        |> halt()

      _other ->
        conn
    end
  end

  def call(conn, _opts), do: conn

  defp query_suffix(""), do: ""
  defp query_suffix(query_string) when is_binary(query_string), do: "?" <> query_string
end
