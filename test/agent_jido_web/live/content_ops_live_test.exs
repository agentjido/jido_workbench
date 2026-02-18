defmodule AgentJidoWeb.ContentOpsLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    admin_conn = conn |> log_in_user(admin_user_fixture())
    %{admin_conn: admin_conn}
  end

  test "redirects unauthenticated users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, "/dev/contentops")
  end

  test "blocks authenticated non-admin users", %{conn: conn} do
    conn = conn |> log_in_user(user_fixture())
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/dev/contentops")
  end

  test "renders dashboard for authenticated admins", %{admin_conn: admin_conn} do
    {:ok, _view, html} = live(admin_conn, "/dev/contentops")

    assert html =~ "ContentOps Dashboard"
    assert html =~ "Workflow Pipeline"
    assert html =~ "Trigger Run"
    assert html =~ "mix agentjido.signal"
  end

  test "public contentops route is not available", %{admin_conn: admin_conn} do
    conn = get(admin_conn, "/contentops")
    assert conn.status == 404
  end
end
