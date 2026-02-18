defmodule AgentJidoWeb.AdminDashboardLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    admin_conn = log_in_user(conn, admin_user_fixture())
    %{admin_conn: admin_conn}
  end

  test "redirects unauthenticated users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, "/dashboard")
  end

  test "blocks authenticated non-admin users", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/dashboard")
  end

  test "renders admin control-plane links for authenticated admins", %{admin_conn: admin_conn} do
    {:ok, view, html} = live(admin_conn, "/dashboard")

    assert html =~ "Admin Control Plane"
    assert has_element?(view, "a[href='/arcana']", "Open Arcana dashboard")
    assert has_element?(view, "a[href='/dev/jido']", "Open Jido Studio")
    assert has_element?(view, "a[href='/dev/contentops']", "Open ContentOps dashboard")

    assert has_element?(
             view,
             "a[href='/dev/contentops/github']",
             "Open ContentOps GitHub dashboard"
           )
  end
end
