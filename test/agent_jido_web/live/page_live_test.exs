defmodule AgentJidoWeb.PageLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Pages

  describe "home auth navigation" do
    test "does not render login link on the home page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      refute html =~ ~s(href="/users/log-in")
    end

    test "renders login link on non-home public pages", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/docs")

      assert html =~ ~s(href="/users/log-in")
    end
  end

  describe "docs" do
    test "renders docs index page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/docs")

      assert html =~ "Jido Documentation"
      assert html =~ "Get Started"
    end

    test "renders docs show page", %{conn: conn} do
      page = Pages.pages_by_category(:docs) |> hd()
      route = Pages.route_for(page)
      {:ok, _view, html} = live(conn, route)

      assert html =~ page.title
    end
  end

  describe "training" do
    test "renders training index page with curriculum modules", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/training")

      assert html =~ "TRAINING TRACK"
      assert html =~ "Practical Jido training for"

      for page <- Pages.pages_by_category(:training) do
        assert html =~ page.title
      end
    end

    test "renders training detail page", %{conn: conn} do
      page = Pages.pages_by_category(:training) |> hd()
      route = Pages.route_for(page)
      {:ok, _view, html} = live(conn, route)

      assert html =~ page.title
      assert html =~ "LEARNING OUTCOMES"
    end

    test "training detail has previous/next navigation", %{conn: conn} do
      training = Pages.pages_by_category(:training)

      if length(training) >= 3 do
        middle = Enum.at(training, 1)
        route = Pages.route_for(middle)
        {:ok, _view, html} = live(conn, route)

        assert html =~ "Previous Module"
        assert html =~ "Next Module"
      end
    end
  end
end
