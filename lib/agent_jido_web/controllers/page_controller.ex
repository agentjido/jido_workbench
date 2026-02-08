defmodule AgentJidoWeb.PageController do
  use AgentJidoWeb, :controller

  def discord(conn, _params) do
    discord_invite_link = Application.get_env(:agent_jido, :discord_invite_link)
    redirect(conn, external: discord_invite_link)
  end
end
