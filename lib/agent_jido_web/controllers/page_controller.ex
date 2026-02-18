defmodule AgentJidoWeb.PageController do
  use AgentJidoWeb, :controller

  def discord(conn, _params) do
    discord_invite_link = Application.get_env(:agent_jido, :discord_invite_link)
    redirect(conn, external: discord_invite_link)
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
