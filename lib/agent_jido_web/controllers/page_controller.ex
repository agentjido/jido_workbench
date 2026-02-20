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
        not_found(conn, %{})
    end
  end

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> put_view(html: AgentJidoWeb.PageHTML)
    |> render(:not_found,
      request_path: conn.request_path,
      page_title: "Page Not Found",
      meta_description: "The requested page could not be found on agentjido.xyz.",
      robots: ["noindex", "nofollow"]
    )
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
