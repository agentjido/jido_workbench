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

    test "smoke routes for required docs IA stubs", %{conn: conn} do
      required_paths = [
        "/docs/core-concepts",
        "/docs/guides",
        "/docs/reference",
        "/docs/architecture",
        "/docs/production-readiness-checklist",
        "/docs/security-and-governance",
        "/docs/incident-playbooks"
      ]

      Enum.each(required_paths, fn path ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, path)
        assert html =~ page.title
      end)
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

  describe "features wave A pages" do
    test "smoke routes for first three feature pages", %{conn: conn} do
      target_routes = [
        {"/features/reliability-by-architecture", "Jido treats reliability as an architectural constraint"},
        {"/features/multi-agent-coordination", "Jido models multi-agent behavior as explicit coordination contracts"},
        {"/features/operations-observability", "The router mounts LiveDashboard with Jido runtime pages enabled"}
      ]

      Enum.each(target_routes, fn {path, expected_copy} ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, path)

        assert html =~ expected_copy
        assert html =~ "Get Building"
        refute html =~ "Content coming soon."
      end)
    end
  end

  describe "features wave B pages" do
    test "smoke routes for remaining four feature pages", %{conn: conn} do
      target_routes = [
        {"/features/incremental-adoption", "You do not need a rewrite to adopt Jido"},
        {"/features/beam-for-ai-builders", "AI builders often hit runtime limits before model limits"},
        {"/features/jido-vs-framework-first-stacks", "This comparison is about operating model, not brand ranking"},
        {"/features/executive-brief", "Jido is a runtime for reliable, multi-agent systems"}
      ]

      Enum.each(target_routes, fn {path, expected_copy} ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, path)

        assert html =~ expected_copy
        assert html =~ "Get Building"
        refute html =~ "Content coming soon."
      end)
    end
  end
end
