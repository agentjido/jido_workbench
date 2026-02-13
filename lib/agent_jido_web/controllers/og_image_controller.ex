defmodule AgentJidoWeb.OGImageController do
  use AgentJidoWeb, :controller
  alias AgentJido.OGImage

  def default(conn, _params) do
    serve_image(conn, OGImage.get_image(:default))
  end

  def home(conn, _params) do
    serve_image(conn, OGImage.get_image(:home))
  end

  def ecosystem(conn, _params) do
    serve_image(conn, OGImage.get_image(:ecosystem))
  end

  def getting_started(conn, _params) do
    serve_image(conn, OGImage.get_image(:getting_started))
  end

  def examples(conn, _params) do
    serve_image(conn, OGImage.get_image(:examples))
  end

  def features(conn, _params) do
    serve_image(conn, OGImage.get_image(:features))
  end

  def training(conn, _params) do
    serve_image(conn, OGImage.get_image(:training))
  end

  def docs(conn, _params) do
    serve_image(conn, OGImage.get_image(:docs))
  end

  def blog(conn, _params) do
    serve_image(conn, OGImage.get_image(:blog))
  end

  def blog_post(conn, %{"slug" => slug}) do
    serve_image(conn, OGImage.get_image({:blog_post, slug}))
  end

  defp serve_image(conn, {:ok, png_data}) do
    conn
    |> put_resp_content_type("image/png")
    |> put_resp_header("cache-control", "public, max-age=86400")
    |> send_resp(200, png_data)
  end

  defp serve_image(conn, {:error, _reason}) do
    fallback_path = Application.app_dir(:agent_jido, "priv/static/images/og-default.png")

    case File.read(fallback_path) do
      {:ok, data} ->
        conn
        |> put_resp_content_type("image/png")
        |> put_resp_header("cache-control", "public, max-age=86400")
        |> send_resp(200, data)

      {:error, _} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(404, "Image not found")
    end
  end
end
