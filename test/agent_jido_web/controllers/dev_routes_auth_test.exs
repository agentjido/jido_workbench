defmodule AgentJidoWeb.DevRoutesAuthTest do
  use AgentJidoWeb.ConnCase, async: true

  import AgentJido.AccountsFixtures

  describe "GET /dashboard" do
    test "redirects unauthenticated users to log in", %{conn: conn} do
      conn = get(conn, ~p"/dashboard")

      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must log in"
    end

    test "blocks authenticated non-admin users", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/dashboard")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must be an admin"
    end

    test "allows authenticated admin users", %{conn: conn} do
      admin_user = admin_user_fixture()

      conn =
        conn
        |> log_in_user(admin_user)
        |> get(~p"/dashboard")

      assert html_response(conn, 200) =~ "Admin Control Plane"
    end
  end

  describe "GET /dashboard/chatops" do
    test "redirects unauthenticated users to log in", %{conn: conn} do
      conn = get(conn, ~p"/dashboard/chatops")

      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must log in"
    end

    test "blocks authenticated non-admin users", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/dashboard/chatops")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must be an admin"
    end

    test "allows authenticated admin users", %{conn: conn} do
      admin_user = admin_user_fixture()

      conn =
        conn
        |> log_in_user(admin_user)
        |> get(~p"/dashboard/chatops")

      assert html_response(conn, 200) =~ "ChatOps Console"
    end
  end

  describe "GET /dev/jido" do
    test "redirects unauthenticated users to log in", %{conn: conn} do
      conn = get(conn, ~p"/dev/jido")

      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must log in"
    end

    test "blocks authenticated non-admin users", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/dev/jido")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must be an admin"
    end

    test "allows authenticated admin users", %{conn: conn} do
      admin_user = admin_user_fixture()

      conn =
        conn
        |> log_in_user(admin_user)
        |> get(~p"/dev/jido")

      assert conn.status in [200, 302]

      if conn.status == 302 do
        assert redirected_to(conn) =~ "/dev/jido"
      end
    end
  end

  describe "GET /arcana" do
    test "redirects unauthenticated users to log in", %{conn: conn} do
      conn = get(conn, ~p"/arcana")

      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must log in"
    end

    test "blocks authenticated non-admin users", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/arcana")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must be an admin"
    end

    test "allows authenticated admin users", %{conn: conn} do
      admin_user = admin_user_fixture()

      conn =
        conn
        |> log_in_user(admin_user)
        |> get(~p"/arcana")

      assert html_response(conn, 200) =~ "/documents"
    end
  end

  describe "GET /dev/mailbox" do
    test "allows unauthenticated users in dev routes", %{conn: conn} do
      conn = get(conn, ~p"/dev/mailbox")

      assert conn.status in [200, 302]

      if conn.status == 302 do
        assert redirected_to(conn) =~ "/dev/mailbox"
      end
    end
  end
end
