defmodule AgentJidoWeb.OGImageController do
  @moduledoc """
  Serves dynamic Open Graph images from route path descriptors.
  """
  use AgentJidoWeb, :controller

  require Logger

  alias AgentJido.OGImage

  @cache_control "public, max-age=3600"

  def render(conn, %{"path" => path_segments}) do
    requested_path = requested_path(path_segments)

    case OGImage.get_image_for_path(requested_path) do
      {:ok, png_data, descriptor} ->
        maybe_send_not_modified(conn, descriptor.content_hash, png_data)

      {:error, reason} ->
        Logger.warning("OG render failure path=#{requested_path} reason=#{inspect(reason)}")
        serve_fallback(conn)
    end
  end

  def render(conn, _params) do
    case OGImage.get_fallback_image() do
      {:ok, png_data, descriptor} ->
        maybe_send_not_modified(conn, descriptor.content_hash, png_data)

      {:error, _reason} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, "Error generating image")
    end
  end

  defp serve_fallback(conn) do
    case OGImage.get_fallback_image() do
      {:ok, png_data, descriptor} ->
        maybe_send_not_modified(conn, descriptor.content_hash, png_data)

      {:error, _reason} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, "Error generating image")
    end
  end

  defp requested_path(path_segments) do
    case path_segments |> List.wrap() |> Enum.reject(&(&1 in [nil, ""])) do
      [] ->
        "/"

      ["home"] ->
        "/"

      segments ->
        "/" <> Enum.join(segments, "/")
    end
    |> String.trim()
    |> case do
      "/" -> "/"
      path -> String.trim_trailing(path, "/")
    end
  end

  defp maybe_send_not_modified(conn, content_hash, png_data) do
    etag = ~s("#{content_hash}")

    if etag_matches?(conn, etag) do
      conn
      |> put_resp_header("etag", etag)
      |> put_resp_header("cache-control", @cache_control)
      |> send_resp(304, "")
    else
      conn
      |> put_resp_content_type("image/png")
      |> put_resp_header("etag", etag)
      |> put_resp_header("cache-control", @cache_control)
      |> send_resp(200, png_data)
    end
  end

  defp etag_matches?(conn, etag) do
    conn
    |> get_req_header("if-none-match")
    |> Enum.any?(fn value ->
      value
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.trim_leading(&1, "W/"))
      |> Enum.any?(fn candidate -> candidate == etag or candidate == "*" end)
    end)
  end
end
