defmodule AgentJidoWeb.ChatOpsLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    admin_conn = log_in_user(conn, admin_user_fixture())
    %{admin_conn: admin_conn}
  end

  test "renders ChatOps shell scaffolding for authenticated admins", %{admin_conn: admin_conn} do
    {:ok, _view, html} = live(admin_conn, "/dashboard/chatops")

    assert html =~ "ChatOps Console"
    assert html =~ "Room List"
    assert html =~ "Messages"
    assert html =~ "Action/Run Timeline"
    assert html =~ "Guardrails"
  end
end
