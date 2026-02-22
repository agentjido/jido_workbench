defmodule AgentJidoWeb.LoggedInUtilityBarTest do
  use AgentJidoWeb.ConnCase, async: true

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  test "does not render utility bar for anonymous visitors", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/features")

    refute html =~ ~s(id="logged-in-utility-bar")
  end

  test "renders settings and logout for authenticated non-admin users", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    {:ok, _view, html} = live(conn, "/features")

    assert html =~ ~s(id="logged-in-utility-bar")
    assert html =~ ~s(href="/users/settings")
    assert html =~ ~s(action="/users/log-out")
    assert html =~ ~s(name="_method" value="delete")
    assert html =~ "Settings"
    assert html =~ "Logout"
    refute html =~ ~s(href="/dashboard")
  end

  test "renders dashboard link for authenticated admins", %{conn: conn} do
    conn = log_in_user(conn, admin_user_fixture())

    {:ok, _view, html} = live(conn, "/features")

    assert html =~ ~s(id="logged-in-utility-bar")
    assert html =~ ~s(href="/dashboard")
    assert html =~ ~s(href="/users/settings")
    assert html =~ ~s(action="/users/log-out")
    assert html =~ ~s(name="_method" value="delete")
    assert html =~ "Dashboard"
    assert html =~ "Settings"
    assert html =~ "Logout"
  end
end
