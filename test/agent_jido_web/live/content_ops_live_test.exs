defmodule AgentJidoWeb.ContentOpsLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  test "renders dashboard on dev route", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/dev/contentops")

    assert html =~ "ContentOps Dashboard"
    assert html =~ "Workflow Pipeline"
    assert html =~ "Trigger Run"
    assert html =~ "mix agentjido.signal"
  end

  test "public contentops route is not available", %{conn: conn} do
    conn = get(conn, "/contentops")
    assert conn.status == 404
  end
end
