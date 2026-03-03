defmodule AgentJidoWeb.Plugs.LLMResponse do
  @moduledoc """
  Adds LLM discovery headers and serves markdown responses for supported
  public routes when clients request `Accept: text/markdown`.

  Also supports explicit `.md` URLs as a deterministic markdown endpoint.
  """
  import Plug.Conn

  alias AgentJidoWeb.MarkdownContent
  alias AgentJidoWeb.MarkdownLinks

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%Plug.Conn{method: method, request_path: request_path} = conn, _opts)
      when method in ["GET", "HEAD"] and is_binary(request_path) do
    case markdown_paths(request_path) do
      {canonical_path, markdown_path} ->
        if MarkdownContent.eligible_public_path?(canonical_path) do
          canonical_url = MarkdownLinks.absolute_url(canonical_path, conn.query_string)
          markdown_url = MarkdownLinks.absolute_url(markdown_path, conn.query_string)

          cond do
            markdown_route_request?(request_path) or markdown_request?(conn) ->
              maybe_render_markdown(conn, canonical_path, canonical_url, markdown_url)

            true ->
              register_discovery_headers(conn, markdown_url)
          end
        else
          conn
        end

      :no_match ->
        conn
    end
  end

  def call(conn, _opts), do: conn

  defp maybe_render_markdown(conn, canonical_path, canonical_url, markdown_url) do
    case MarkdownContent.resolve(canonical_path, canonical_url) do
      {:ok, markdown} ->
        conn
        |> put_discovery_headers(markdown_url)
        |> put_markdown_seo_headers(canonical_url)
        |> put_resp_content_type("text/markdown", "utf-8")
        |> send_resp(200, markdown)
        |> halt()

      :no_match ->
        register_discovery_headers(conn, markdown_url)
    end
  end

  defp register_discovery_headers(conn, markdown_url) do
    register_before_send(conn, fn conn ->
      put_discovery_headers(conn, markdown_url)
    end)
  end

  defp put_discovery_headers(conn, markdown_url) do
    conn
    |> put_vary_accept()
    |> put_markdown_alternate_link_header(markdown_url)
  end

  defp put_markdown_seo_headers(conn, canonical_url) do
    conn
    |> put_resp_header("x-robots-tag", "noindex")
    |> put_canonical_link_header(canonical_url)
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

  defp put_markdown_alternate_link_header(conn, markdown_url) do
    add_link_entries(conn, [
      "</llms.txt>; rel=\"alternate\"; type=\"text/plain\"",
      "<#{markdown_url}>; rel=\"alternate\"; type=\"text/markdown\""
    ])
  end

  defp put_canonical_link_header(conn, canonical_url) do
    add_link_entries(conn, ["<#{canonical_url}>; rel=\"canonical\""])
  end

  defp add_link_entries(conn, entries) do
    existing =
      conn
      |> get_resp_header("link")
      |> Enum.flat_map(&parse_comma_separated_values/1)

    merged =
      (existing ++ entries)
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

  defp markdown_paths(path) do
    cond do
      path == "/index.md" ->
        {"/", "/index.md"}

      markdown_route_request?(path) ->
        canonical = String.trim_trailing(path, ".md")

        if canonical == "" do
          :no_match
        else
          {canonical, path}
        end

      true ->
        {path, suffix_markdown_path(path)}
    end
  end

  defp suffix_markdown_path("/"), do: "/index.md"
  defp suffix_markdown_path(path), do: path <> ".md"

  defp markdown_route_request?(path) when is_binary(path) do
    String.ends_with?(path, ".md")
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
