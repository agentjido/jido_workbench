defmodule AgentJidoWeb.AnalyticsIdentityTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJidoWeb.Plugs.AnalyticsIdentity

  defmodule IdentityProbeLive do
    use AgentJidoWeb, :live_view

    @impl true
    def render(assigns) do
      ~H"""
      <div id="analytics-visitor">{@analytics_identity.visitor_id}</div>
      <div id="analytics-session">{@analytics_identity.session_id}</div>
      """
    end
  end

  test "plug assigns visitor and session identity", %{conn: conn} do
    conn =
      conn
      |> Map.put(:secret_key_base, String.duplicate("a", 64))
      |> init_test_session(%{})
      |> AnalyticsIdentity.call([])

    identity = conn.assigns.analytics_identity

    assert is_binary(identity.visitor_id)
    assert is_binary(identity.session_id)
    assert get_session(conn, :analytics_session_id) == identity.session_id
    assert conn.resp_cookies["_agent_jido_visitor_id"]
    assert is_binary(conn.resp_cookies["_agent_jido_visitor_id"].value)
  end

  test "on-mount exposes analytics identity to liveviews", %{conn: conn} do
    session = %{
      "analytics_identity" => %{
        "visitor_id" => "visitor-live",
        "session_id" => "session-live",
        "path" => "/docs"
      }
    }

    {:ok, _view, html} = live_isolated(conn, IdentityProbeLive, session: session)

    assert html =~ "visitor-live"
    assert html =~ "session-live"
  end
end
