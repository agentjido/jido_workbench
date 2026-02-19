defmodule AgentJidoWeb.PageController do
  use AgentJidoWeb, :controller

  alias AgentJido.Pages

  def discord(conn, _params) do
    discord_invite_link = Application.get_env(:agent_jido, :discord_invite_link)
    redirect(conn, external: discord_invite_link)
  end

  def docs_legacy_redirect(conn, _params) do
    case Pages.resolve_page_for_path(conn.request_path) do
      {:ok, page, :legacy} ->
        conn
        |> put_status(:moved_permanently)
        |> redirect(to: Pages.route_for(page))

      _other ->
        send_resp(conn, :not_found, "Not found")
    end
  end

  def arcana_redirect(conn, params) do
    path =
      params
      |> Map.get("path", [])
      |> List.wrap()
      |> Enum.join("/")

    target =
      case path do
        "" -> "/arcana"
        _ -> "/arcana/" <> path
      end

    target =
      case conn.query_string do
        "" -> target
        query -> target <> "?" <> query
      end

    redirect(conn, to: target)
  end

  def arcana_legacy_app_js(conn, _params) do
    redirect(conn, to: "/assets/app.js")
  end
end
