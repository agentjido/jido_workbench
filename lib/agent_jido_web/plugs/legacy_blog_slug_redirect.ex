defmodule AgentJidoWeb.Plugs.LegacyBlogSlugRedirect do
  @moduledoc """
  Redirects legacy blog slugs to canonical slugs with HTTP 301.
  """
  import Plug.Conn

  alias AgentJido.Blog.SlugAlias

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%Plug.Conn{method: method, request_path: request_path} = conn, _opts)
      when method in ["GET", "HEAD"] and is_binary(request_path) do
    case extract_slug(request_path) do
      {:ok, slug} ->
        maybe_redirect(conn, slug)

      :skip ->
        conn
    end
  end

  def call(conn, _opts), do: conn

  defp extract_slug("/blog/tags/" <> _tag), do: :skip

  defp extract_slug("/blog/" <> slug) do
    if String.contains?(slug, "/") or String.trim(slug) == "" do
      :skip
    else
      {:ok, slug}
    end
  end

  defp extract_slug(_path), do: :skip

  defp maybe_redirect(conn, slug) do
    case SlugAlias.canonical_slug_for(slug) do
      canonical when is_binary(canonical) and canonical != "" and canonical != slug ->
        destination = "/blog/" <> canonical <> query_suffix(conn.query_string)

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
