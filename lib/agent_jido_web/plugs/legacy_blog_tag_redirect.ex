defmodule AgentJidoWeb.Plugs.LegacyBlogTagRedirect do
  @moduledoc """
  Redirects legacy blog tags to canonical tag routes with HTTP 301.
  """
  import Plug.Conn

  alias AgentJido.Blog.TagAlias

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%Plug.Conn{method: method, request_path: request_path} = conn, _opts)
      when method in ["GET", "HEAD"] and is_binary(request_path) do
    case extract_tag(request_path) do
      {:ok, tag} -> maybe_redirect(conn, tag)
      :skip -> conn
    end
  end

  def call(conn, _opts), do: conn

  defp extract_tag("/blog/tags/" <> tag) do
    if String.contains?(tag, "/") or String.trim(tag) == "" do
      :skip
    else
      {:ok, String.trim(tag)}
    end
  end

  defp extract_tag(_path), do: :skip

  defp maybe_redirect(conn, tag) do
    case TagAlias.canonical_tag_for(tag) do
      canonical when is_binary(canonical) and canonical != "" and canonical != tag ->
        destination = "/blog/tags/" <> canonical <> query_suffix(conn.query_string)

        conn
        |> put_resp_header("location", destination)
        |> send_resp(301, "")
        |> halt()

      _ ->
        conn
    end
  end

  defp query_suffix(""), do: ""
  defp query_suffix(query_string) when is_binary(query_string), do: "?" <> query_string
end
