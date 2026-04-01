defmodule AgentJidoWeb.EcosystemBookmarksController do
  @moduledoc """
  Public bookmarks export for the Jido ecosystem repositories.
  """
  use AgentJidoWeb, :controller

  alias AgentJido.Ecosystem.Bookmarks

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{Bookmarks.filename()}"))
    |> send_resp(200, Bookmarks.export_html())
  end
end
