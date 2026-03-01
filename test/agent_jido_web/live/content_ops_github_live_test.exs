defmodule AgentJidoWeb.ContentOpsGithubLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  @moduletag :content_ops

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    original_token = System.get_env("GITHUB_TOKEN")
    System.delete_env("GITHUB_TOKEN")

    on_exit(fn ->
      if original_token do
        System.put_env("GITHUB_TOKEN", original_token)
      else
        System.delete_env("GITHUB_TOKEN")
      end
    end)

    admin_conn = conn |> log_in_user(admin_user_fixture())

    %{admin_conn: admin_conn}
  end

  test "redirects unauthenticated users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, "/dashboard/contentops/github")
  end

  test "blocks authenticated non-admin users", %{conn: conn} do
    conn = conn |> log_in_user(user_fixture())
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/dashboard/contentops/github")
  end

  test "renders github dashboard on control-plane route", %{admin_conn: admin_conn} do
    {:ok, _view, html} = live(admin_conn, "/dashboard/contentops/github")

    assert html =~ "GitHub Issues &amp; PRs"
    assert html =~ "GITHUB_TOKEN environment variable is not set."
    assert html =~ ~s(data-admin-nav-path="/dashboard/contentops/github")
  end

  test "blocks mutating events when github mutations are disabled", %{admin_conn: admin_conn} do
    {:ok, view, _html} = live(admin_conn, "/dashboard/contentops/github")

    html =
      render_hook(view, "solve_issue", %{
        "number" => "10",
        "title" => "Example issue"
      })

    assert html =~ "GitHub mutations are disabled for this environment."

    html =
      render_hook(view, "merge_pr", %{
        "number" => "22",
        "title" => "Example PR"
      })

    assert html =~ "GitHub mutations are disabled for this environment."
  end

  test "public github route is not available", %{admin_conn: admin_conn} do
    conn = get(admin_conn, "/contentops/github")
    assert conn.status == 404
  end
end
